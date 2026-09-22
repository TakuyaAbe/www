// www.sayuno.me → sayuno.me へ 301。それ以外は静的アセットをそのまま返す。
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.hostname === "www.sayuno.me") {
      url.hostname = "sayuno.me";
      return Response.redirect(url.toString(), 301);
    }
    return env.ASSETS.fetch(request);
  },
};
