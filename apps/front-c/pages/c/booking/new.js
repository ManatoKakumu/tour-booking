import { useRouter } from "next/router";
import { useEffect, useState } from "react";

export default function NewBooking() {
  const router = useRouter();
  const [tour, setTour] = useState(null);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const tourId = Number(router.query.tour_id);

  useEffect(() => {
    if (!router.isReady) return;
    if (!Number.isInteger(tourId) || tourId <= 0) {
      setError("ツアーが指定されていません");
      return;
    }
    fetch(`/api/tours/${tourId}/`)
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        setTour(data.tour);
      })
      .catch(() => setError("ツアーが見つかりません"));
  }, [router.isReady, tourId]);

  async function handleCheckout() {
    setSubmitting(true);
    setError("");
    const res = await fetch("/c/booking/api/bookings/", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-Requested-With": "fetch" },
      body: JSON.stringify({ tour_id: tourId }),
    });
    const data = await res.json();
    if (!res.ok) {
      setSubmitting(false);
      setError(data.error || "予約に失敗しました");
      return;
    }
    // Stripe Checkoutの決済画面へ遷移する
    window.location.href = data.checkout_url;
  }

  if (error) return <p>{error}</p>;
  if (tour === null) return <p>読み込み中...</p>;

  return (
    <>
      <h1>予約内容の確認</h1>
      <p>
        <strong>{tour.title}</strong>
      </p>
      <p>{tour.price.toLocaleString()}円(1名)</p>
      <button onClick={handleCheckout} disabled={submitting || tour.remaining === 0}>
        {submitting ? "決済画面へ移動中..." : "決済へ進む"}
      </button>
    </>
  );
}
