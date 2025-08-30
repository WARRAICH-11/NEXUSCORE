import { NextRequest } from "next/server";
import { stripe } from "@/lib/stripe";
import { env } from "@/env";

export const runtime = "nodejs";

export async function POST(req: NextRequest) {
  const sig = req.headers.get("stripe-signature");
  if (!env.STRIPE_WEBHOOK_SECRET || !sig) {
    return new Response("Missing webhook secret or signature", { status: 400 });
  }

  let event;
  try {
    const body = await req.text();
    event = stripe.webhooks.constructEvent(body, sig, env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return new Response(`Webhook Error: ${message}`, { status: 400 });
  }

  // TODO: handle events (invoice.paid, invoice.payment_failed, customer.subscription.updated, usage events)

  return new Response(JSON.stringify({ received: true, type: event.type }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
}
