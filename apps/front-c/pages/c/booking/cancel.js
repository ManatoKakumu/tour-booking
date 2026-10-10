import { useRouter } from "next/router";
import { useEffect, useState } from "react";

// Stripe Checkoutのcancel_url。決済をやめた予約を取り消し、確保していた枠を戻す
export default function BookingCancel() {
  const router = useRouter();
  const [message, setMessage] = useState("予約を取り消しています...");

  useEffect(() => {
    if (!router.isReady) return;
    const bookingId = Number(router.query.booking_id);
    if (!Number.isInteger(bookingId) || bookingId <= 0) {
      setMessage("予約が指定されていません");
      return;
    }
    fetch(`/c/booking/api/bookings/${bookingId}/cancel/`, {
      method: "POST",
      headers: { "X-Requested-With": "fetch" },
    })
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        setMessage("決済を中止し、予約を取り消しました。");
      })
      .catch((e) => setMessage(e.message || "予約の取り消しに失敗しました"));
  }, [router.isReady, router.query.booking_id]);

  return (
    <>
      <p>{message}</p>
      <a href="/tours/">ツアー一覧へ戻る</a>
    </>
  );
}
