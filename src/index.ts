export interface Env {
  ASSETS: Fetcher;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/api/health") {
      return Response.json({
        ok: true,
        package: "SpaceFollowKit",
        mode: "cloudflare-workers-static-assets",
      });
    }

    return env.ASSETS.fetch(request);
  },
};
