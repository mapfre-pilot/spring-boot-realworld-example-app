const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const legacyFile = path.resolve(__dirname, "../../../legacy/ES_VIDA_372VENCIMIENTOSMANUALES/2 - DES Desarrollo/3 - Programacion/JAVA/WSS372VENCIMIENTOSMANUALES/Web Content/js/GestionExpedienteVen.js");
const source = fs.readFileSync(legacyFile, "utf8");
const marker = /function\s+precisionDecimales\s*\([^)]*\)\s*\{/g;
const match = marker.exec(source);
if (!match) throw new Error("No se encontró precisionDecimales en GestionExpedienteVen.js");

let position = source.indexOf("{", match.index);
let depth = 0;
do {
  if (source[position] === "{") depth++;
  if (source[position] === "}") depth--;
  position++;
} while (depth > 0 && position < source.length);
const functionSource = source.slice(match.index, position);
const context = {};
vm.runInNewContext(functionSource, context);

const precisionDecimales = context.precisionDecimales;
const cases = [
  {name: "neto", bruto: 1000, primas: 10, transitoria: 5},
  {name: "decimal", bruto: 1000.005, primas: 10, transitoria: 5},
  {name: "empate-binario", bruto: 1.005, primas: 0, transitoria: 0},
  {name: "cero", bruto: 0, primas: 0, transitoria: 0},
];
for (const sample of cases) {
  const neto = precisionDecimales(sample.bruto - sample.primas - sample.transitoria, 2);
  console.log(JSON.stringify({caso: sample.name, netoLegacy: String(neto)}));
}
