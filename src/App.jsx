export default function App() {
  return (
    <main className="page">
      <section className="hero">
        <p className="eyebrow">Mini pagina demo</p>
        <h1>Seu projeto React no ar com Docker</h1>
        <p className="subtitle">
          Uma pagina pequena, moderna e pronta para testar no navegador.
        </p>
        <button className="cta" type="button">
          Comecar agora
        </button>
      </section>

      <section className="grid">
        <article className="card">
          <h2>Rapido</h2>
          <p>Suba em poucos segundos com uma imagem Docker simples.</p>
        </article>
        <article className="card">
          <h2>Leve</h2>
          <p>Layout enxuto, responsivo e com foco em boa leitura.</p>
        </article>
        <article className="card">
          <h2>Escalavel</h2>
          <p>Base facil para evoluir para dashboard ou pagina comercial.</p>
        </article>
      </section>
    </main>
  );
}
