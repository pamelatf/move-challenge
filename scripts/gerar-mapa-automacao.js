// Gera a página "11 · Mapa da automação" da wiki a partir dos próprios testes.
//
// Cada teste traz no nome um identificador e as regras que cobre, por exemplo:
//   test('UNI-06 [RN1] treino e dia leve valem 1 ponto cada', ...)
//   it('REG-02 [RN9] participante não marca o dia de outra pessoa', ...)
//   # E2E-02 [RN1, RN6] Marcação do dia de hoje ...   (primeira linha do fluxo Maestro)
//
// Uso, na pasta do repositório:
//   node scripts/gerar-mapa-automacao.js [caminho-de-saida]
//
// Sem argumento, grava em ../move-challenge.wiki/11-Mapa-da-automação.md

const fs = require('fs');
const path = require('path');

const RAIZ = path.resolve(__dirname, '..');
const SAIDA = process.argv[2] || path.join(RAIZ, '..', 'move-challenge.wiki', '11-Mapa-da-automação.md');
const REPO = 'https://github.com/pamelatf/move-challenge/blob/main';

const TIPOS = {
  UNI: { nome: 'Unidade', ferramenta: 'flutter_test' },
  WID: { nome: 'Widget', ferramenta: 'flutter_test' },
  REG: { nome: 'Regras do banco', ferramenta: 'Mocha e emulador do Firestore' },
  E2E: { nome: 'Ponta a ponta', ferramenta: 'Maestro em emulador Android' },
};
const REGRAS = ['RN1', 'RN2', 'RN3', 'RN4', 'RN5', 'RN6', 'RN7', 'RN8', 'RN9', 'RN10'];

function arquivos(pasta, extensao) {
  const absoluta = path.join(RAIZ, pasta);
  if (!fs.existsSync(absoluta)) return [];
  return fs.readdirSync(absoluta, { withFileTypes: true }).flatMap((e) => {
    const relativo = path.join(pasta, e.name);
    if (e.isDirectory()) return e.name === 'node_modules' || e.name === 'subflows' ? [] : arquivos(relativo, extensao);
    return e.name.endsWith(extensao) ? [relativo] : [];
  });
}

const PADRAO_CODIGO = /(?:test|testWidgets|it)\(\s*['"]((UNI|WID|REG)-\d+) \[([^\]]+)\] ([^'"]+)['"]/g;
const PADRAO_FLUXO = /^#\s*((E2E)-\d+) \[([^\]]+)\] (.+)$/m;

const testes = [];
for (const arquivo of [...arquivos('test', '_test.dart'), ...arquivos('firestore-tests/test', '.test.js')]) {
  const texto = fs.readFileSync(path.join(RAIZ, arquivo), 'utf8');
  for (const m of texto.matchAll(PADRAO_CODIGO)) {
    testes.push({ id: m[1], tipo: m[2], regras: m[3].split(',').map((r) => r.trim()), descricao: m[4].trim(), arquivo });
  }
}
for (const arquivo of arquivos('.maestro', '.yaml')) {
  const m = fs.readFileSync(path.join(RAIZ, arquivo), 'utf8').match(PADRAO_FLUXO);
  if (m) testes.push({ id: m[1], tipo: m[2], regras: m[3].split(',').map((r) => r.trim()), descricao: m[4].trim(), arquivo });
}
testes.sort((a, b) => a.id.localeCompare(b.id, 'pt', { numeric: true }));

const repetidos = testes.map((t) => t.id).filter((id, i, todos) => todos.indexOf(id) !== i);
if (repetidos.length) {
  console.error(`Identificadores repetidos: ${[...new Set(repetidos)].join(', ')}`);
  process.exit(1);
}

const barra = (p) => p.split(path.sep).join('/');
const linhas = [];
linhas.push('Esta página é **gerada por script** e não deve ser editada à mão. Ela é produzida por `scripts/gerar-mapa-automacao.js`, que lê os arquivos de teste do repositório e extrai de cada teste o identificador e as regras que ele cobre.');
linhas.push('', 'Quando um teste for criado ou renomeado, rode o script e publique a wiki de novo:', '', '```', 'node scripts/gerar-mapa-automacao.js', '```');

linhas.push('', '## Resumo', '', '| Tipo | Ferramenta | Testes |', '|---|---|---|');
for (const [sigla, t] of Object.entries(TIPOS)) {
  linhas.push(`| ${t.nome} (\`${sigla}\`) | ${t.ferramenta} | ${testes.filter((x) => x.tipo === sigla).length} |`);
}
linhas.push(`| **Total** | | **${testes.length}** |`);

linhas.push('', '## Cobertura por regra de negócio', '');
linhas.push('Quantos testes de cada tipo exercitam cada regra. Um teste pode cobrir mais de uma regra.', '');
linhas.push(`| Regra | ${Object.keys(TIPOS).join(' | ')} | Total |`, `|---|${Object.keys(TIPOS).map(() => '---').join('|')}|---|`);
for (const rn of REGRAS) {
  const porTipo = Object.keys(TIPOS).map((s) => testes.filter((t) => t.tipo === s && t.regras.includes(rn)).length);
  const total = testes.filter((t) => t.regras.includes(rn)).length;
  linhas.push(`| ${rn} | ${porTipo.join(' | ')} | ${total === 0 ? '**0**' : total} |`);
}
const semCobertura = REGRAS.filter((rn) => !testes.some((t) => t.regras.includes(rn)));
if (semCobertura.length) {
  linhas.push('', `Regras sem nenhum teste automatizado: **${semCobertura.join(', ')}**. A cobertura delas depende dos casos e sessões manuais.`);
}

for (const [sigla, t] of Object.entries(TIPOS)) {
  const doTipo = testes.filter((x) => x.tipo === sigla);
  if (!doTipo.length) continue;
  linhas.push('', `## ${t.nome}`, '', '| ID | Regras | O que verifica | Arquivo |', '|---|---|---|---|');
  for (const x of doTipo) {
    const arq = barra(x.arquivo);
    linhas.push(`| ${x.id} | ${x.regras.join(', ')} | ${x.descricao} | [\`${path.basename(arq)}\`](${REPO}/${encodeURI(arq)}) |`);
  }
}

fs.mkdirSync(path.dirname(SAIDA), { recursive: true });
fs.writeFileSync(SAIDA, linhas.join('\n') + '\n', 'utf8');
console.log(`Mapa gerado com ${testes.length} testes em ${SAIDA}`);
