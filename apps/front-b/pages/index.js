import { useEffect, useState } from "react";

// basePathはfetchには自動で付かないため、APIのパスは絶対パスで書く
const API = "/b/api";

const styles = {
  main: { maxWidth: 720, margin: "0 auto", padding: 16, fontFamily: "sans-serif" },
  form: { display: "grid", gap: 8, marginBottom: 32 },
  card: { border: "1px solid #ccc", borderRadius: 8, padding: 12, marginBottom: 12 },
  image: { maxWidth: "100%", maxHeight: 200, display: "block", marginBottom: 8 },
  error: { color: "#c00" },
};

export default function GuideHome() {
  const [tours, setTours] = useState([]);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function loadTours() {
    const res = await fetch(`${API}/tours/`);
    const data = await res.json();
    if (!res.ok) {
      setError(data.error || "ツアー一覧の取得に失敗しました");
      return;
    }
    setTours(data.tours);
  }

  useEffect(() => {
    loadTours();
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const formData = new FormData(form);
    // 画像未選択時は空のファイルが入るため送らない
    if (!formData.get("image")?.size) formData.delete("image");

    setSubmitting(true);
    setError("");
    const res = await fetch(`${API}/tours/`, {
      method: "POST",
      headers: { "X-Requested-With": "fetch" },
      body: formData,
    });
    const data = await res.json();
    setSubmitting(false);
    if (!res.ok) {
      setError(data.error || "登録に失敗しました");
      return;
    }
    form.reset();
    loadTours();
  }

  return (
    <main style={styles.main}>
      <h1>ガイド管理画面</h1>

      <h2>ツアーを登録する</h2>
      <form style={styles.form} onSubmit={handleSubmit}>
        <label>
          タイトル
          <input name="title" required maxLength={100} style={{ width: "100%" }} />
        </label>
        <label>
          説明
          <textarea name="description" rows={3} style={{ width: "100%" }} />
        </label>
        <label>
          価格(円)
          <input name="price" type="number" min={1} required />
        </label>
        <label>
          定員
          <input name="capacity" type="number" min={1} required />
        </label>
        <label>
          画像(JPEG・PNG・WebP、5MBまで)
          <input name="image" type="file" accept="image/jpeg,image/png,image/webp" />
        </label>
        <button type="submit" disabled={submitting}>
          {submitting ? "登録中..." : "登録"}
        </button>
      </form>

      {error && <p style={styles.error}>{error}</p>}

      <h2>登録済みのツアー</h2>
      {tours.length === 0 && <p>まだツアーがありません。</p>}
      {tours.map((tour) => (
        <div key={tour.id} style={styles.card}>
          {/* 画像はCloudFrontの /images/* ビヘイビア経由でS3から配信される */}
          {tour.image_key && <img src={`/${tour.image_key}`} alt="" style={styles.image} />}
          <strong>{tour.title}</strong>
          <p>{tour.description}</p>
          <p>
            {tour.price.toLocaleString()}円 / 残り {tour.remaining} / 定員 {tour.capacity}
          </p>
        </div>
      ))}
    </main>
  );
}
