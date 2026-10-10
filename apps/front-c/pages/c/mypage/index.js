import { useEffect, useState } from "react";

const STATUS_LABELS = { pending: "決済待ち", confirmed: "確定", canceled: "取消" };

export default function MyPage() {
  const [bookings, setBookings] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    fetch("/c/mypage/api/bookings/")
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        setBookings(data.bookings);
      })
      .catch(() => setError("予約一覧の取得に失敗しました"));
  }, []);

  if (error) return <p>{error}</p>;
  if (bookings === null) return <p>読み込み中...</p>;

  return (
    <>
      <h1>マイページ</h1>
      <h2>予約一覧</h2>
      {bookings.length === 0 && <p>予約はありません。</p>}
      <ul>
        {bookings.map((b) => (
          <li key={b.id}>
            {b.tour.title} / {b.amount.toLocaleString()}円 / {STATUS_LABELS[b.status] || b.status}
          </li>
        ))}
      </ul>
    </>
  );
}
