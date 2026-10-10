// トップページ(/)はCloudFrontが静的配信用S3のindex.htmlを返すため、通常は到達しない。
// ALBのヘルスチェック(/)用に残している
export default function Home() {
  return <div>front-c OK</div>;
}
