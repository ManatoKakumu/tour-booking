import { useRouter } from "next/router";
import { useEffect, useState } from "react";

// Stripe Checkoutのsuccess_url。session_idを使ってapi-c側で支払い状態を確認し、予約を確定する
export default function BookingComplete() {
  const router = useRouter();
  const [booking, setBooking] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!router.isReady) return;
    fetch("/c/booking/api/bookings/confirm/", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-Requested-With": "fetch" },
      body: JSON.stringify({ session_id: router.query.session_id }),
    })
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        setBooking(data.booking);
      })
      .catch(() => setError("予約の確認に失敗しました。マイページで状態を確認してください。"));
  }, [router.isReady, router.query.session_id]);

  if (error) return <p>{error}</p>;
  if (booking === null) return <p>決済結果を確認しています...</p>;

  return (
    <>
      <h1>{booking.status === "confirmed" ? "予約が確定しました" : "決済を確認中です"}</h1>
      <p>
        {booking.tour.title} / {booking.amount.toLocaleString()}円
      </p>
      <a href="/c/mypage/">マイページで予約を確認する</a>
    </>
  );
}
