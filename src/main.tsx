import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App";

console.log('🚀 Aplicació iniciant-se...');

const rootElement = document.getElementById("root");
if (!rootElement) {
  console.error('❌ No s\'ha trobat l\'element #root al HTML!');
} else {
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>
  );
  console.log('✅ React s\'ha renderitzat correctament.');
}
