import { createClient } from "@supabase/supabase-js";
import { env } from "./env";

// The single Supabase client for the whole app (Blueprint Section 3, canonical).
// Every data-access file (features/*/api.ts) imports this — nothing else
// should call createClient again.
export const supabase = createClient(
  env.supabaseUrl,
  env.supabasePublishableKey,
);
