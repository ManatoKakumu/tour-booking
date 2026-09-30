"""
【本人実装】Stripe APIの呼び出し

api-cからStripeへの通信は、NAT Gateway経由のegressのみ許可されている
(SGのアウトバウンドはStripe公開IPを同期したプレフィックスリストに限定)。
"""

import os
from dataclasses import dataclass

import stripe

# 既定では応答を最大80秒待ち、通信失敗時は2回まで再試行する(最悪約4分)。
# Stripeに届かない場合に利用者を長く待たせないよう、タイムアウトを短くする
stripe.default_http_client = stripe.RequestsClient(timeout=10)


@dataclass
class CheckoutSession:
    id: str
    url: str


def create_checkout_session(*, booking, tour, success_url, cancel_url):
    # シークレットキーは環境変数で受け取る(本番はECSタスク定義のsecretsでSecrets Managerから注入)
    session = stripe.checkout.Session.create(
        api_key=os.environ["STRIPE_SECRET_KEY"],
        mode="payment",
        line_items=[
            {
                "price_data": {
                    "currency": "jpy",
                    "unit_amount": booking.amount,
                    "product_data": {"name": tour.title},
                },
                "quantity": 1,
            }
        ],
        success_url=success_url,
        cancel_url=cancel_url,
        client_reference_id=str(booking.id),
    )
    return CheckoutSession(id=session.id, url=session.url)


def get_payment_status(session_id):
    session = stripe.checkout.Session.retrieve(
        session_id,
        api_key=os.environ["STRIPE_SECRET_KEY"],
    )
    return session.payment_status
