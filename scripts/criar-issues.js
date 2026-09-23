// Cadastra as issues de teste do Move Challenge no GitHub e as adiciona ao Project.
//
// Pré-requisitos:
//   1. GitHub CLI instalada e autenticada:  gh auth login
//   2. Permissão para Projects:            gh auth refresh -s project
//
// Uso (na pasta do repositório):
//   node scripts/criar-issues.js
//
// O script pode ser executado mais de uma vez: issues com o mesmo título
// não são criadas de novo.

const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const REPO = 'pamelatf/move-challenge';
const DONO = 'pamelatf';
const TITULO_PROJECT = 'Move Challenge: Testes';
const PASTA_DOCS = 'docs/testes';

function gh(args, { silencioso = false } = {}) {
  try {
    return execFileSync('gh', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    if (!silencioso) console.error(`  Erro ao executar gh ${args.slice(0, 2).join(' ')}: ${(e.stderr || e.message).trim()}`);
    return null;
  }
}

const RN = [
  ['RN1', 'Dia de treino ou dia leve vale 1 ponto.'],
  ['RN2', 'Treino com alguém do desafio (junto ou por chamada de vídeo) vale +1; não se aplica ao coringa.'],
  ['RN3', 'Sequências de 7, 14 e 30 dias seguidos valem +3, +5 e +10 pontos.'],
  ['RN4', 'Cada pessoa tem um coringa por mês: vale 0 ponto e não quebra a sequência.'],
  ['RN5', 'Só é possível marcar dias entre o início do desafio e hoje; dias marcados podem ser editados e desmarcados.'],
  ['RN6', 'O ranking ordena por pontos, depois pela maior sequência atual, depois por nome; há os períodos "Este mês" e "Desde o início".'],
  ['RN7', 'Acesso por conta de e-mail e senha, com cadastro, login e recuperação de senha.'],
  ['RN8', 'O desafio é criado com um código de 6 caracteres, usado pelas demais pessoas para entrar.'],
  ['RN9', 'Só participantes veem os dados do desafio; cada pessoa altera apenas os próprios dias.'],
  ['RN10', 'Ao sair do desafio, os dias marcados pela pessoa são apagados e ela deixa o ranking.'],
];

const CONDICOES = [
  ['CT-01', 'A pontuação exibida para cada tipo de dia', 'Alta', 'RN1'],
  ['CT-02', 'O ponto extra do treino com alguém e sua indisponibilidade no coringa', 'Média', 'RN2'],
  ['CT-03', 'A concessão do bônus ao atingir 7, 14 e 30 dias e a exibição da comemoração', 'Alta', 'RN3'],
  ['CT-04', 'A quebra da sequência por um dia vazio e sua preservação pelo coringa', 'Alta', 'RN3, RN4'],
  ['CT-05', 'O limite de um coringa por mês, inclusive na virada do mês', 'Alta', 'RN4'],
  ['CT-06', 'O bloqueio de dias futuros e anteriores ao início do desafio', 'Média', 'RN5'],
  ['CT-07', 'A edição e o desmarcar de dias já registrados, com reflexo na pontuação', 'Alta', 'RN5'],
  ['CT-08', 'Os critérios de desempate e a troca de período do ranking', 'Alta', 'RN6'],
  ['CT-09', 'A atualização do ranking em outro aparelho após uma marcação', 'Alta', 'RN6, RN9'],
  ['CT-10', 'As validações de cadastro, login e recuperação de senha', 'Média', 'RN7'],
  ['CT-11', 'A criação do desafio e a entrada com código válido, inválido e digitado em minúsculas', 'Alta', 'RN8'],
  ['CT-12', 'A remoção dos dados e do ranking ao sair do desafio', 'Média', 'RN10'],
  ['CT-13', 'A marcação sem internet e a sincronização ao reconectar', 'Alta', 'RN5, RN9'],
];

const CASOS = [
  { id: 'CT-001', titulo: 'Validar que o dia de treino marcado hoje soma 1 ponto no mês', prio: 'Alta', rast: 'CT-01 (RN1)',
    pre: ['Usuária logada e participante de um desafio já iniciado', 'Dia de hoje ainda sem marcação', 'Valor atual de "pontos no mês" anotado'],
    passos: [['Abrir o aplicativo', 'Aba Marcar é exibida com as estatísticas e o calendário do mês'], ['Tocar em "Marcar hoje"', 'Folha de marcação abre com a data de hoje por extenso'], ['Selecionar "Treinei"', 'Opção fica destacada e o botão Salvar é habilitado'], ['Tocar em "Salvar"', 'Aviso "Dia salvo"; o dia de hoje exibe o ícone de treino e "pontos no mês" aumenta em 1']],
    pos: ['O ranking mostra +1 ponto para a usuária em "Este mês" e em "Desde o início"', 'Outra participante vê a atualização no próprio aparelho'] },
  { id: 'CT-002', titulo: 'Validar que o bônus de +3 é concedido e a comemoração exibida ao completar 7 dias seguidos', prio: 'Alta', rast: 'CT-03 (RN3)',
    pre: ['Desafio com data de início no dia 1 do mês atual ou antes', 'Os 6 dias anteriores a hoje marcados como treino, todos no mês atual', 'Dia de hoje sem marcação; estatística mostra 6 dias seguidos'],
    passos: [['Abrir a aba Marcar', 'Estatística de sequência exibe 6 dias seguidos'], ['Tocar em "Marcar hoje", selecionar "Treinei" e tocar em "Salvar"', 'Tela de comemoração exibe "7 dias seguidos", "+3 pontos de bônus" e a próxima meta de 14 dias'], ['Tocar em "Continuar"', 'Retorno à aba Marcar com 7 dias seguidos e "pontos no mês" aumentado em 4']],
    pos: ['No ranking, os detalhes da usuária exibem "+3 de bônus"'] },
  { id: 'CT-003', titulo: 'Validar que o segundo coringa no mesmo mês fica indisponível', prio: 'Alta', rast: 'CT-05 (RN4)',
    pre: ['Coringa já usado em um dia do mês atual', 'Outro dia passado do mesmo mês sem marcação'],
    passos: [['Observar a estatística de coringas', 'Exibe 0 coringas restantes'], ['Tocar no dia passado sem marcação', 'Folha de marcação abre'], ['Observar a opção "Usar coringa"', 'Opção desabilitada com o texto "Coringa do mês já usado"'], ['Tocar na opção "Usar coringa"', 'Nada é selecionado e o botão Salvar continua desabilitado']],
    pos: ['Nenhuma marcação é criada para o dia'] },
  { id: 'CT-004', titulo: 'Validar que desmarcar um dia remove sua pontuação e quebra a sequência', prio: 'Alta', rast: 'CT-07 (RN5)',
    pre: ['Anteontem, ontem e hoje marcados como treino, no mês atual', 'Estatística mostra 3 dias seguidos'],
    passos: [['Tocar no dia de ontem no calendário', 'Folha abre com "Treinei" selecionado e o botão "Desmarcar dia" visível'], ['Tocar em "Desmarcar dia"', 'Aviso "Dia desmarcado"; o dia de ontem fica sem marcação'], ['Observar as estatísticas', '"Pontos no mês" diminui em 1 e a sequência passa a 1 dia']],
    pos: ['O ranking reflete a nova pontuação para todas as participantes'] },
  { id: 'CT-005', titulo: 'Validar o desempate do ranking pela maior sequência atual', prio: 'Alta', rast: 'CT-08 (RN6)',
    pre: ['Participantes A e B com a mesma pontuação no mês', 'A com dias marcados ontem e hoje (sequência 2)', 'B com dias marcados no início do mês e sequência atual 0'],
    passos: [['Abrir a aba Ranking com o período "Este mês"', 'A aparece acima de B, ambas com a mesma pontuação'], ['Trocar para "Desde o início"', 'A ordem é recalculada pela pontuação total, mantendo o mesmo critério de desempate']],
    pos: ['N/A'] },
  { id: 'CT-006', titulo: 'Validar a entrada em um desafio com o código digitado em minúsculas', prio: 'Alta', rast: 'CT-11 (RN8)',
    pre: ['Desafio existente com código conhecido', 'Segunda conta criada e ainda sem desafio'],
    passos: [['Entrar no app com a segunda conta', 'Tela "Entre no desafio" é exibida'], ['Digitar o código em letras minúsculas', 'O campo exibe o código em letras maiúsculas'], ['Tocar em "Entrar no desafio"', 'Aba Marcar é exibida com o nome do desafio no topo'], ['Abrir a aba Perfil', 'A nova participante aparece na lista do grupo']],
    pos: ['A nova participante aparece no ranking, com 0 pontos, para as demais participantes'] },
];

const SESSOES = [
  ['S01', 'Cadastro e login', 'o cadastro e o login', 'Ataques de strings e de tipos de dados (Test Heuristics Cheat Sheet)', 'se as validações aceitam ou rejeitam entradas de forma coerente e com mensagens claras', 'CT-10'],
  ['S02', 'Marcação diária', 'a marcação diária', 'Sabedoria em Testes, com foco em adotar a abordagem contrária', 'se o app impede ações contrárias às regras, como dois coringas, coringa com treino em dupla e dias futuros', 'CT-02, CT-05, CT-06'],
  ['S03', 'Sequências e bônus', 'as sequências e os bônus', 'a dimensão Tempo do HTSM (virada de dia e de mês, relógio do aparelho alterado)', 'se o cálculo de sequência depende do relógio de forma frágil', 'CT-03, CT-04'],
  ['S04', 'Sincronização', 'o uso simultâneo em dois aparelhos', 'Flow Testing do HTSM e a heurística de Interrupções (modo avião, app fechado no meio da ação)', 'se marcações concorrentes ou interrompidas geram dados inconsistentes', 'CT-09, CT-13'],
  ['S05', 'Ranking e Regras', 'o ranking e a tela de Regras', 'Claims Testing do HTSM e os oráculos FEW HICCUPPS', 'se o que o app promete na tela de Regras corresponde ao que ele calcula', 'CT-01, CT-08'],
  ['S06', 'Interface', 'as telas Marcar, Ranking e Perfil', 'a heurística ALTR FACE, adaptada a componentes mobile', 'se folha de marcação, botão flutuante e avisos se sobrepõem, somem na hora errada ou ficam inalcançáveis', 'Todas'],
  ['S07', 'Acessibilidade', 'a marcação do dia e o ranking', 'o critério Usability do HTSM (TalkBack, fonte ampliada e tema escuro)', 'se uma pessoa com baixa visão consegue marcar o dia e entender sua posição', 'CT-01, CT-08'],
  ['S08', 'Ciclo de vida dos dados', 'a edição de nome e a saída do desafio', 'CRUD e Siga os Dados (Test Heuristics Cheat Sheet)', 'se as alterações se propagam para o ranking, o calendário e os aparelhos das outras participantes', 'CT-12'],
  ['S09', 'Cenário completo', 'uma semana típica de uma participante', 'Scenario Testing e User Testing do HTSM', 'se a experiência completa faz sentido para quem não é da área de tecnologia', 'Todas'],
];

const ETIQUETAS = [
  ['tipo: caso de teste', '1D76DB', 'Caso de teste roteirizado (ISO 29119-3)'],
  ['tipo: sessão', '5E8C6A', 'Sessão de teste exploratório (SBTM)'],
  ['tipo: defeito', 'B3261E', 'Defeito encontrado nos testes'],
  ['tipo: melhoria', 'D4A017', 'Sugestão de melhoria para versões futuras'],
  ['prioridade: alta', 'B84E02', ''],
  ['prioridade: média', 'E0621A', ''],
  ['prioridade: baixa', 'FCE0CF', ''],
  ['severidade: alta', '7A1A14', ''],
  ['severidade: média', 'E27D74', ''],
  ['severidade: baixa', 'F9DEDC', ''],
];

const semAcento = (t) => t.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
const prioridade = (p) => `prioridade: ${semAcento(p) === 'media' ? 'média' : semAcento(p)}`;
const lista = (itens) => itens.map((i) => `- ${i}`).join('\n');

const issues = [];

for (const c of CASOS) {
  issues.push({
    titulo: `${c.id} · ${c.titulo}`,
    etiquetas: ['tipo: caso de teste', prioridade(c.prio)],
    corpo: [
      '## Caso de teste',
      '', `| Campo | Valor |`, '|---|---|',
      `| ID | ${c.id} |`, `| Prioridade | ${c.prio} |`, `| Rastreabilidade | ${c.rast} |`,
      '', '### Pré-condições', lista(c.pre),
      '', '### Passos', '', '| Passo | Ação | Resultado esperado |', '|---|---|---|',
      ...c.passos.map((s, i) => `| ${i + 1} | ${s[0]} | ${s[1]} |`),
      '', '### Pós-condições', lista(c.pos),
      '', '### Execuções', '- [ ] Execução 1: data, resultado e evidência',
      '', `Documento: \`${PASTA_DOCS}/02-Casos-de-Teste.docx\``,
    ].join('\n'),
  });
}

for (const s of SESSOES) {
  issues.push({
    titulo: `${s[0]} · ${s[1]}`,
    etiquetas: ['tipo: sessão'],
    corpo: [
      '## Charter', '',
      `**Explore** ${s[2]}`, `**Com** ${s[3]}`, `**Para descobrir** ${s[4]}`,
      '', `**Tamanho da sessão:** 45 minutos`, `**Condições relacionadas:** ${s[5]}`,
      '', '## Relatório (preencher após a execução)',
      '', '**Data e hora do início:** ', '', '**Notas** ((I)nformações ou (R)iscos):', '- (I) ', '- (R) ',
      '', '**Defeitos:**', '- ', '', '**Perguntas:**', '- ',
      '', '**Métricas TBS** (teste / defeitos / preparação): __ % / __ % / __ %',
      '**Charter / oportunidade:** __ % / __ %',
      '', `Documento: \`${PASTA_DOCS}/03-Sessoes-Exploratorias.docx\``,
    ].join('\n'),
  });
}

issues.push({
  titulo: 'DEF-001 · Erro ao abrir o desafio logo após criá-lo no primeiro acesso',
  etiquetas: ['tipo: defeito', 'prioridade: alta', 'severidade: média'],
  corpo: [
    '## Defeito', '',
    '| Campo | Valor |', '|---|---|',
    '| ID | DEF-001 |', '| Testadora | Pâmela Tábata |', '| Data | 23/09/2026 (horário a confirmar) |',
    '| Prioridade | Alta: ocorre no primeiro contato de cada participante nova |',
    '| Severidade | Média: existe contorno (sair e entrar) e não há perda de dados |',
    '| Software | Move Challenge 1.0.0+1, versão web no Chrome (Windows 10), Firebase move-challenge-b5aa8 |',
    '| Rastreabilidade | CT-11 (RN8); sessão S04 |', '| Status | Novo |',
    '', '### Passos para reproduzir',
    '1. Criar uma conta nova', '2. Na tela "Entre no desafio", tocar em "Criar novo desafio"',
    '3. Informar nome e data de início e tocar em "Criar desafio"', '4. Seguir para o desafio',
    '', '### Resultado esperado', 'Após a criação, a tela principal do desafio é carregada normalmente.',
    '', '### Resultado atual',
    'A tela "Não foi possível abrir o desafio" é exibida, orientando a sair e entrar novamente. Após sair e entrar, o desafio abre normalmente. Intermitente: não se repetiu nas criações seguintes.',
    '', '### Evidências', 'Vídeo da reprodução (a anexar).',
    '', '### Análise inicial (hipótese, a confirmar)',
    'O perfil local passa a apontar para o novo desafio antes de o servidor confirmar a participação. Se a tela principal ler o desafio nesse intervalo, as regras de segurança negam a leitura e a tela exibe o erro sem nova tentativa. Para confirmar, reproduzir com a rede limitada (Chrome, perfil Slow 4G).',
    '', `Documento: \`${PASTA_DOCS}/04-Defeitos.docx\``,
  ].join('\n'),
});

issues.push({
  titulo: 'MEL-001 · Participar de mais de um desafio',
  etiquetas: ['tipo: melhoria'],
  corpo: [
    '## Melhoria', '',
    '**História:** como participante, quero criar ou entrar em mais de um desafio sem sair do atual, para competir com grupos diferentes ao mesmo tempo.',
    '', '**Situação atual:** cada conta participa de um único desafio. Para criar ou entrar em outro, é preciso sair do atual, o que apaga os dias marcados.',
    '', '### Critérios de aceite',
    '- [ ] Lista dos desafios de que a pessoa participa',
    '- [ ] Alternância entre desafios sem perder dados',
    '- [ ] Criação e entrada em novo desafio sem sair dos demais',
    '- [ ] Pontuação, sequência, coringa e ranking independentes em cada desafio',
    '- [ ] Sair de um desafio não afeta os demais',
    '', '**Prioridade:** a definir (candidata à versão 2.0)',
    '', `Documento: \`${PASTA_DOCS}/05-Backlog-de-Melhorias.docx\``,
  ].join('\n'),
});

function numeroDoProject() {
  const saida = gh(['project', 'list', '--owner', DONO, '--format', 'json'], { silencioso: true });
  if (!saida) return null;
  const encontrado = JSON.parse(saida).projects.find((p) => p.title === TITULO_PROJECT);
  return encontrado ? String(encontrado.number) : null;
}

function main() {
  if (!gh(['--version'], { silencioso: true })) {
    console.error('GitHub CLI não encontrada. Instale com: winget install GitHub.cli');
    process.exit(1);
  }

  console.log('Criando etiquetas...');
  for (const [nome, cor, descricao] of ETIQUETAS) {
    gh(['label', 'create', nome, '--repo', REPO, '--color', cor, '--description', descricao, '--force']);
  }

  const existentes = new Set(
    JSON.parse(gh(['issue', 'list', '--repo', REPO, '--state', 'all', '--limit', '500', '--json', 'title']) || '[]')
      .map((i) => i.title),
  );

  const projeto = numeroDoProject();
  if (!projeto) {
    console.log(`Project "${TITULO_PROJECT}" não encontrado. As issues serão criadas, mas não adicionadas ao Project.`);
    console.log('Confira o título do Project e se rodou: gh auth refresh -s project');
  }

  const temporario = path.join(os.tmpdir(), 'move-challenge-issue.md');
  let criadas = 0;
  for (const issue of issues) {
    if (existentes.has(issue.titulo)) {
      console.log(`Já existe: ${issue.titulo}`);
      continue;
    }
    fs.writeFileSync(temporario, issue.corpo, 'utf8');
    const args = ['issue', 'create', '--repo', REPO, '--title', issue.titulo, '--body-file', temporario];
    for (const e of issue.etiquetas) args.push('--label', e);
    const url = gh(args);
    if (!url) continue;
    criadas++;
    console.log(`Criada: ${issue.titulo}`);
    if (projeto) gh(['project', 'item-add', projeto, '--owner', DONO, '--url', url.trim()]);
  }
  fs.rmSync(temporario, { force: true });
  console.log(`\nConcluído: ${criadas} issue(s) criada(s) de ${issues.length}.`);
}

main();
