import { useEffect, useState } from "react";
import { supabase } from "../lib/supabaseClient";

// Temporary: proves the browser can reach Supabase and that RLS blocks a
// signed-out request. Milestone 6 replaces this whole file with real routing
// and screens.
export default function App() {
  const [status, setStatus] = useState("Checking Supabase connection…");

  useEffect(() => {
    supabase
      .from("profiles")
      .select("user_id")
      .then(({ error }) => {
        if (error?.code === "42501") {
          setStatus(
            "Connected. Supabase correctly refused this signed-out request (42501).",
          );
        } else if (error) {
          setStatus(
            `Connected, but got an unexpected response: ${error.code} — ${error.message}`,
          );
        } else {
          setStatus(
            "Connected, but unexpectedly got data back with no one signed in.",
          );
        }
      });
  }, []);

  return (
    <main className="p-6">
      <h1 className="text-4xl font-bold tracking-tight">ChronosSpend</h1>
      <p className="mt-2 text-stone-600">
        Setup complete. The calendar comes later.
      </p>
      <p className="mt-4 text-sm text-stone-500">{status}</p>
    </main>
  );
}
