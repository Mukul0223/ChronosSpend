// Reads and validates the environment variables the app needs at startup.
// This is the ONLY file that reads import.meta.env (Blueprint Section 4.5).

function fail(message: string): never {
  throw new Error(`Configuration error: ${message}`);
}

const url = import.meta.env.VITE_SUPABASE_URL;
const publishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;
const siteUrl = import.meta.env.VITE_SITE_URL;

if (!url) {
  fail(
    "VITE_SUPABASE_URL is missing. Copy .env.example to .env.local and fill it in.",
  );
}
if (!url.startsWith("https://") || !url.endsWith(".supabase.co")) {
  fail("VITE_SUPABASE_URL must start with https:// and end with .supabase.co");
}

if (!publishableKey) {
  fail(
    "VITE_SUPABASE_PUBLISHABLE_KEY is missing. Copy .env.example to .env.local and fill it in.",
  );
}
if (
  publishableKey.startsWith("sb_secret_") ||
  publishableKey.startsWith("eyJ")
) {
  // eyJ... is what a legacy service_role JWT looks like. Either shape means a
  // secret key ended up somewhere only the publishable key should ever be.
  fail(
    "VITE_SUPABASE_PUBLISHABLE_KEY looks like a secret or service_role key. " +
      "Only the publishable key (sb_publishable_...) belongs in the browser.",
  );
}
if (!publishableKey.startsWith("sb_publishable_")) {
  fail("VITE_SUPABASE_PUBLISHABLE_KEY must start with sb_publishable_");
}

if (!siteUrl) {
  fail(
    "VITE_SITE_URL is missing. Copy .env.example to .env.local and fill it in.",
  );
}
if (siteUrl.endsWith("/")) {
  fail("VITE_SITE_URL must not have a trailing slash");
}

export const env = {
  supabaseUrl: url,
  supabasePublishableKey: publishableKey,
  siteUrl: siteUrl,
};
