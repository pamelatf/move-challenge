const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, deleteDoc } = require('firebase/firestore');

let ambiente;

const bancoDe = (uid) =>
  uid ? ambiente.authenticatedContext(uid).firestore() : ambiente.unauthenticatedContext().firestore();

async function semear() {
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    const db = contexto.firestore();
    await setDoc(doc(db, 'users/ana'), { nome: 'Ana', email: 'ana@email.com', desafioId: 'd1' });
    await setDoc(doc(db, 'codigos/AMG7K2'), { desafioId: 'd1' });
    await setDoc(doc(db, 'desafios/d1'), {
      nome: 'Desafio das amigas',
      codigo: 'AMG7K2',
      dataInicio: '2026-09-01',
      criadoPor: 'ana',
    });
    await setDoc(doc(db, 'desafios/d1/participantes/ana'), { nome: 'Ana', cor: 1 });
    await setDoc(doc(db, 'desafios/d1/participantes/bia'), { nome: 'Bia', cor: 2 });
    await setDoc(doc(db, 'desafios/d1/marcacoes/bia_2026-09-10'), {
      uid: 'bia',
      data: '2026-09-10',
      tipo: 'treino',
      comAmigo: false,
    });
  });
}

const marcacao = (uid, data, extra = {}) => ({
  uid,
  data,
  tipo: 'treino',
  comAmigo: false,
  ...extra,
});

before(async () => {
  ambiente = await initializeTestEnvironment({
    projectId: 'demo-move-challenge',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await ambiente.cleanup();
});

beforeEach(async () => {
  await ambiente.clearFirestore();
  await semear();
});

describe('Marcações', () => {
  it('REG-01 [RN9] participante marca o próprio dia', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe('ana'), 'desafios/d1/marcacoes/ana_2026-09-11'), marcacao('ana', '2026-09-11')),
    );
  });

  it('REG-02 [RN9] participante não marca o dia de outra pessoa', async () => {
    await assertFails(
      setDoc(doc(bancoDe('ana'), 'desafios/d1/marcacoes/bia_2026-09-11'), marcacao('bia', '2026-09-11')),
    );
  });

  it('REG-03 [RN5, RN9] o id do documento precisa combinar com a pessoa e a data', async () => {
    await assertFails(
      setDoc(doc(bancoDe('ana'), 'desafios/d1/marcacoes/ana_2026-09-12'), marcacao('ana', '2026-09-11')),
    );
  });

  it('REG-04 [RN1] recusa tipo de atividade desconhecido', async () => {
    await assertFails(
      setDoc(
        doc(bancoDe('ana'), 'desafios/d1/marcacoes/ana_2026-09-11'),
        marcacao('ana', '2026-09-11', { tipo: 'maratona' }),
      ),
    );
  });

  it('REG-05 [RN2, RN4] recusa coringa marcado como treino com alguém', async () => {
    await assertFails(
      setDoc(
        doc(bancoDe('ana'), 'desafios/d1/marcacoes/ana_2026-09-11'),
        marcacao('ana', '2026-09-11', { tipo: 'coringa', comAmigo: true }),
      ),
    );
  });

  it('REG-06 [RN9] quem não participa não marca dias', async () => {
    await assertFails(
      setDoc(doc(bancoDe('carol'), 'desafios/d1/marcacoes/carol_2026-09-11'), marcacao('carol', '2026-09-11')),
    );
  });

  it('REG-07 [RN9] participante não apaga a marcação de outra pessoa', async () => {
    await assertFails(deleteDoc(doc(bancoDe('ana'), 'desafios/d1/marcacoes/bia_2026-09-10')));
  });

  it('REG-08 [RN5] participante apaga a própria marcação', async () => {
    await assertSucceeds(deleteDoc(doc(bancoDe('bia'), 'desafios/d1/marcacoes/bia_2026-09-10')));
  });
});

describe('Leitura do desafio', () => {
  it('REG-09 [RN9] participante lê o desafio e as marcações do grupo', async () => {
    await assertSucceeds(getDoc(doc(bancoDe('ana'), 'desafios/d1')));
    await assertSucceeds(getDoc(doc(bancoDe('ana'), 'desafios/d1/marcacoes/bia_2026-09-10')));
  });

  it('REG-10 [RN9] quem não participa não lê o desafio', async () => {
    await assertFails(getDoc(doc(bancoDe('carol'), 'desafios/d1')));
  });

  it('REG-11 [RN9] sem login não lê nada', async () => {
    await assertFails(getDoc(doc(bancoDe(null), 'desafios/d1')));
    await assertFails(getDoc(doc(bancoDe(null), 'codigos/AMG7K2')));
  });
});

describe('Códigos de convite', () => {
  it('REG-12 [RN8] quem está logado consulta um código', async () => {
    await assertSucceeds(getDoc(doc(bancoDe('carol'), 'codigos/AMG7K2')));
  });

  it('REG-13 [RN8] código existente não pode ser sobrescrito', async () => {
    await assertFails(setDoc(doc(bancoDe('carol'), 'codigos/AMG7K2'), { desafioId: 'outro' }));
  });

  it('REG-14 [RN8] código com formato inválido é recusado', async () => {
    await assertFails(setDoc(doc(bancoDe('carol'), 'codigos/ABC0O1'), { desafioId: 'd2' }));
  });
});

describe('Participantes e perfis', () => {
  it('REG-15 [RN8] pessoa entra no desafio com o próprio usuário', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe('carol'), 'desafios/d1/participantes/carol'), { nome: 'Carol', cor: 3 }),
    );
  });

  it('REG-16 [RN9] ninguém inclui outra pessoa no desafio', async () => {
    await assertFails(
      setDoc(doc(bancoDe('carol'), 'desafios/d1/participantes/dani'), { nome: 'Dani', cor: 4 }),
    );
  });

  it('REG-17 [RN9] perfil só pode ser lido pela própria pessoa', async () => {
    await assertSucceeds(getDoc(doc(bancoDe('ana'), 'users/ana')));
    await assertFails(getDoc(doc(bancoDe('bia'), 'users/ana')));
  });
});
