const styles = {
  main: { maxWidth: 720, margin: "0 auto", padding: 16, fontFamily: "sans-serif" },
  nav: { display: "flex", gap: 16, marginBottom: 24 },
};

export default function App({ Component, pageProps }) {
  return (
    <main style={styles.main}>
      {/* 認証の要否でALBの振り分け先・Cognitoリダイレクトが変わるため、ページ遷移は通常の<a>で行う */}
      <nav style={styles.nav}>
        <a href="/">トップ</a>
        <a href="/tours/">ツアー一覧</a>
        <a href="/c/mypage/">マイページ</a>
      </nav>
      <Component {...pageProps} />
    </main>
  );
}
