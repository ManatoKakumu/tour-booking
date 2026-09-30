/** @type {import('next').NextConfig} */
module.exports = {
  // ALBは /b/* のみをfront-bへ振り分けるため、ページ・JS/CSS(/_next/*)をすべて /b 配下に置く。
  // basePath無しだと /_next/* がデフォルトルールでfront-cへ流れ、front-bの画面が動かない
  basePath: "/b",
  // ALBのパスパターン(/b/* 等)に一致させるため、URLを末尾スラッシュ付きに統一する
  trailingSlash: true,
};
