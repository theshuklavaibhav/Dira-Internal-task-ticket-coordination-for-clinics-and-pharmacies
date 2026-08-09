export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    const authHeader = request.headers.get("X-Dira-Secret");
    if (authHeader !== env.WORKER_SHARED_SECRET) {
      return new Response("Unauthorized", { status: 401 });
    }

    if (request.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    if (url.pathname === "/send-push") return handleSendPush(request, env);
    if (url.pathname === "/create-order") return handleCreateOrder(request, env);
    if (url.pathname === "/verify-payment") return handleVerifyPayment(request, env);

    return new Response("Not found", { status: 404 });
  },
};

// ---------- Push notifications ----------

async function handleSendPush(request, env) {
  const { externalUserId, title, message, data } = await request.json();
  if (!externalUserId || !message) {
    return new Response("Missing externalUserId or message", { status: 400 });
  }

  const response = await fetch("https://onesignal.com/api/v1/notifications", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      Authorization: `Basic ${env.ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: env.ONESIGNAL_APP_ID,
      include_aliases: { external_id: [externalUserId] },
      target_channel: "push",
      headings: { en: title || "Dira" },
      contents: { en: message },
      data: data || {},
    }),
  });

  const result = await response.json();
  return new Response(JSON.stringify(result), {
    status: response.status,
    headers: { "Content-Type": "application/json" },
  });
}

// ---------- Billing: create order ----------

// async function handleCreateOrder(request, env) {
//   const { clinicId, planAmount } = await request.json();

//   const auth = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_KEY_SECRET}`);
//   const res = await fetch("https://api.razorpay.com/v1/orders", {
//     method: "POST",
//     headers: { Authorization: `Basic ${auth}`, "Content-Type": "application/json" },
//     body: JSON.stringify({
//       amount: planAmount,
//       currency: "INR",
//       receipt: `dira_${clinicId}_${Date.now()}`,
//       notes: { clinicId },
//     }),
//   });
//   const order = await res.json();

//   return new Response(
//     JSON.stringify({ orderId: order.id, amount: order.amount, keyId: env.RAZORPAY_KEY_ID }),
//     { headers: { "Content-Type": "application/json" } }
//   );
// }

async function handleCreateOrder(request, env) {
  const { clinicId, planAmount } = await request.json();

  const auth = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_KEY_SECRET}`);
  const res = await fetch("https://api.razorpay.com/v1/orders", {
    method: "POST",
    headers: { Authorization: `Basic ${auth}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      amount: planAmount,
      currency: "INR",
      receipt: `dira_${clinicId}_${Date.now()}`,
      notes: { clinicId },
    }),
  });
  const rawText = await res.text();
  console.log("RAZORPAY RAW RESPONSE:", res.status, rawText); // ← temporary debug line

  let order;
  try {
    order = JSON.parse(rawText);
  } catch (e) {
    return new Response(JSON.stringify({ error: "Non-JSON response from Razorpay", raw: rawText }), {
      status: 502,
      headers: { "Content-Type": "application/json" },
    });
  }

  if (!res.ok || !order.id) {
    return new Response(JSON.stringify({ error: order.error || order }), {
      status: res.status || 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(
    JSON.stringify({ orderId: order.id, amount: order.amount, keyId: env.RAZORPAY_KEY_ID }),
    { headers: { "Content-Type": "application/json" } }
  );
}

// ---------- Billing: verify payment ----------

async function handleVerifyPayment(request, env) {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature, clinicId } = await request.json();

  const body = `${razorpay_order_id}|${razorpay_payment_id}`;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(env.RAZORPAY_KEY_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sigBuffer = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const expectedSig = Array.from(new Uint8Array(sigBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  if (expectedSig !== razorpay_signature) {
    return new Response(JSON.stringify({ verified: false }), { status: 400 });
  }

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  await updateClinicPlan(env, clinicId, expiresAt.toISOString());

  return new Response(JSON.stringify({ verified: true }), {
    headers: { "Content-Type": "application/json" },
  });
}

async function getAccessToken(env) {
  const serviceAccount = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/datastore",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const b64 = (obj) =>
    btoa(JSON.stringify(obj)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const unsigned = `${b64(header)}.${b64(payload)}`;

  const pem = serviceAccount.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const keyBytes = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsigned)
  );
  const encodedSig = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  const jwt = `${unsigned}.${encodedSig}`;
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const data = await tokenRes.json();
  return data.access_token;
}

async function updateClinicPlan(env, clinicId, expiresAtIso) {
  const accessToken = await getAccessToken(env);
  const url = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/clinics/${clinicId}?updateMask.fieldPaths=plan&updateMask.fieldPaths=subscriptionExpiresAt&updateMask.fieldPaths=subscriptionActivatedAt`;

  await fetch(url, {
    method: "PATCH",
    headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        plan: { stringValue: "active" },
        subscriptionExpiresAt: { timestampValue: expiresAtIso },
        subscriptionActivatedAt: { timestampValue: new Date().toISOString() },
      },
    }),
  });
}