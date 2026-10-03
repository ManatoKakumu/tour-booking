import { useEffect, useState } from "react";

const styles = {
  card: { border: "1px solid #ccc", borderRadius: 8, padding: 12, marginBottom: 12 },
  image: { maxWidth: "100%", maxHeight: 200, display: "block", marginBottom: 8 },
};

export default function Tours() {
  const [tours, setTours] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    fetch("/api/tours/")
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error);
        setTours(data.tours);
      })
      .catch(() => setError("ツアー一覧の取得に失敗しました"));
  }, []);

  if (error) return <p>{error}</p>;
  if (tours === null) return <p>読み込み中...</p>;

  return (
    <>
      <h1>ツアー一覧</h1>
      {tours.length === 0 && <p>現在予約できるツアーはありません。</p>}
      {tours.map((tour) => (
        <div key={tour.id} style={styles.card}>
          {/* 画像はCloudFrontの /images/* ビヘイビア経由でS3から配信される */}
          {tour.image_key && <img src={`/${tour.image_key}`} alt="" style={styles.image} />}
          <strong>{tour.title}</strong>
          <p>{tour.description}</p>
          <p>
            {tour.price.toLocaleString()}円 / 残り {tour.remaining}
          </p>
          {tour.remaining > 0 ? (
            // /c/booking/* はCognito C認証が必要。未ログインならALBがログイン画面へリダイレクトする
            <a href={`/c/booking/new/?tour_id=${tour.id}`}>予約する</a>
          ) : (
            <span>満席</span>
          )}
        </div>
      ))}
    </>
  );
}
