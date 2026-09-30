/** @type {import('next').NextConfig} */
module.exports = {
  // ALBのパスパターン(/c/mypage/*・/c/booking/*)に一致させるため、URLを末尾スラッシュ付きに統一する
  trailingSlash: true,
};
