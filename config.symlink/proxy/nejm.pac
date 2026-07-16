// NEJM 機構訂閱：只讓 *.nejm.org 走院內 HTTP proxy（經 chameleon 到達），其餘直連
// proxy 172.16.254.142:3128 = 院方出口，Cloudflare/NEJM 認得院方 IP → 機構全文權限
function FindProxyForURL(url, host) {
  if (dnsDomainIs(host, ".nejm.org") || host === "nejm.org") {
    return "PROXY 172.16.254.142:3128";
  }
  return "DIRECT";
}
