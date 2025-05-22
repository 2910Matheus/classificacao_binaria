<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Detecção Binária</title>
  <style>
    /* ==========================
       Estilização global e tema
    ========================== */
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      padding: 0;
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #121212, #1e1e1e, #212121);
      background-size: 400% 400%;
      animation: gradientBG 15s ease infinite;
      color: #ffffff;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      transition: background 0.3s, color 0.3s;
      position: relative;
    }

    @keyframes gradientBG {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }

    body.light {
      background: #f4f4f4;
      color: #111;
    }

    /* ==========================
       Container com fundo blur
    ========================== */
    .container {
      background: rgba(30, 30, 30, 0.6);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.1);
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 0 20px rgba(0, 255, 255, 0.2);
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    body.light .container {
      background-color: white;
      color: black;
    }

    .container > div:first-of-type {
      font-size: 24px;
      font-weight: bold;
      margin-bottom: 20px;
    }

    /* ==========================
       Botões estilizados
    ========================== */
    button {
      padding: 12px 24px;
      font-size: 16px;
      background-color: #1e88e5;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      margin-bottom: 20px;
      transition: background-color 0.3s;
    }

    button:hover {
      background-color: #1565c0;
    }

    /* ==========================
       Canvas da detecção
    ========================== */
    canvas {
      border: 4px solid #1e88e5;
      border-radius: 8px;
      background-color: black;
    }

    /* ==========================
       Labels de classificação
    ========================== */
    #label-container {
      margin-top: 20px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
    }

    #label-container div {
      background-color: #1e1e1e;
      padding: 8px 16px;
      border-radius: 6px;
      font-size: 16px;
      color: #00e676;
      animation: fadeIn 0.5s ease;
      transition: transform 0.3s ease;
    }

    #label-container div:hover {
      transform: scale(1.05);
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* ==========================
       Indicador de carregamento
    ========================== */
    #loader {
      color: #1e88e5;
      font-size: 18px;
      margin-bottom: 20px;
      animation: blink 1.2s infinite;
    }

    @keyframes blink {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }

    /* ==========================
       Painel de status e FPS
    ========================== */
    #info-panel {
      position: absolute;
      top: 20px;
      right: 20px;
      background: #1e1e1e;
      padding: 10px 20px;
      border-radius: 10px;
      color: #00e676;
      font-family: monospace;
      box-shadow: 0 0 10px rgba(0,255,0,0.2);
    }

    body.light #label-container div {
      background-color: #e0f2f1;
      color: #00695c;
    }

    body.light #info-panel {
      background-color: #e0f2f1;
      color: #004d40;
    }

    /* ==========================
       Responsividade
    ========================== */
    @media (max-width: 500px) {
      canvas {
        width: 100%;
        height: auto;
      }

      button {
        width: 90%;
      }

      #info-panel {
        position: static;
        margin-top: 10px;
      }
    }
  </style>
</head>
<body>
  <!-- Painel de informações -->
  <div id="info-panel">
    <p>Status: <span id="status">Aguardando</span></p>
    <p>FPS: <span id="fps">0</span></p>
  </div>

  <!-- Interface principal -->
  <div class="container">
    <div>Detecção Binária</div>
    <div id="loader">Carregando câmera...</div>

    <!-- Botões de controle -->
    <button onclick="init()">▶️ Iniciar detecção</button>
    <button onclick="stopWebcam()">⏹️ Parar detecção</button>

    <!-- Canvas de vídeo -->
    <div><canvas id="canvas"></canvas></div>

    <!-- Previsões -->
    <div id="label-container"></div>

    <!-- Temas e matriz -->
    <button onclick="toggleTheme()">🌙 Mudar tema</button>
    <button onclick="showConfusionMatrix()">📊 Ver Matriz de Confusão</button>
    <div id="confusion-matrix" style="margin-top: 20px;"></div>
  </div>

  <!-- Scripts -->
  <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@1.3.1/dist/tf.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@teachablemachine/pose@0.8/dist/teachablemachine-pose.min.js"></script>

  <script>
    const URL = "./my_model/";
    let model, webcam, ctx, labelContainer, maxPredictions;
    let lastTimestamp = performance.now();
    let animationId;

    let confusionMatrixData = {}; // Armazena os dados da matriz
    let threshold = 0.9; // Confiança mínima para registrar

    // Inicializa a câmera e o modelo
    async function init() {
      document.getElementById("status").textContent = "Carregando modelo...";

      const modelURL = URL + "model.json";
      const metadataURL = URL + "metadata.json";

      model = await tmPose.load(modelURL, metadataURL);
      maxPredictions = model.getTotalClasses();

      const size = 200;
      const flip = true;
      webcam = new tmPose.Webcam(size, size, flip);
      await webcam.setup();
      await webcam.play();
      animationId = window.requestAnimationFrame(loop);

      const canvas = document.getElementById("canvas");
      canvas.width = size;
      canvas.height = size;
      ctx = canvas.getContext("2d");

      labelContainer = document.getElementById("label-container");
      labelContainer.innerHTML = "";
      for (let i = 0; i < maxPredictions; i++) {
        labelContainer.appendChild(document.createElement("div"));
      }

      document.getElementById("loader").style.display = "none";
      document.getElementById("status").textContent = "Detectando...";
    }

    // Encerra a webcam
    function stopWebcam() {
      if (webcam && webcam.stop) {
        webcam.stop();
        document.getElementById("status").textContent = "Parado";
        cancelAnimationFrame(animationId);
      }
    }

    // Loop de detecção (FPS, previsão, render)
    async function loop(timestamp) {
      const delta = (timestamp - lastTimestamp) / 1000;
      const fps = (1 / delta).toFixed(1);
      lastTimestamp = timestamp;
      document.getElementById("fps").textContent = fps;

      webcam.update();
      await predict();
      animationId = window.requestAnimationFrame(loop);
    }

    // Realiza a previsão com o modelo
    async function predict() {
      const { pose, posenetOutput } = await model.estimatePose(webcam.canvas);
      const prediction = await model.predict(posenetOutput);

      // Pega a previsão mais confiável
      let topPrediction = prediction.reduce((max, p) => p.probability > max.probability ? p : max, prediction[0]);

      // Armazena na matriz de confusão se confiável
      if (topPrediction.probability >= threshold) {
        const predicted = topPrediction.className;
        const actual = predicted; // Pode ser substituído por valor real conhecido
        updateConfusionMatrix(actual, predicted);
      }

      // Atualiza os rótulos na interface
      for (let i = 0; i < maxPredictions; i++) {
        const classPrediction = prediction[i].className + ": " + prediction[i].probability.toFixed(2);
        labelContainer.childNodes[i].innerHTML = classPrediction;
      }

      drawPose(pose);
    }

    // Desenha os pontos da pose na tela
    function drawPose(pose) {
      if (webcam.canvas) {
        ctx.drawImage(webcam.canvas, 0, 0);
        if (pose) {
          const minPartConfidence = 0.5;
          tmPose.drawKeypoints(pose.keypoints, minPartConfidence, ctx);
          tmPose.drawSkeleton(pose.keypoints, minPartConfidence, ctx);
        }
      }
    }

    // Alterna entre tema claro e escuro
    function toggleTheme() {
      document.body.classList.toggle("light");
    }

    // Atualiza a matriz de confusão
    function updateConfusionMatrix(actual, predicted) {
      if (!confusionMatrixData[actual]) confusionMatrixData[actual] = {};
      if (!confusionMatrixData[actual][predicted]) confusionMatrixData[actual][predicted] = 0;
      confusionMatrixData[actual][predicted]++;
    }

    // Mostra a matriz de confusão na tela
    function showConfusionMatrix() {
      const container = document.getElementById("confusion-matrix");
      let html = "<h3>Matriz de Confusão</h3><table border='1' style='border-collapse:collapse;text-align:center;'>";

      const labels = Object.keys(confusionMatrixData);
      html += "<tr><th>Real \\ Previsto</th>";
      labels.forEach(label => html += `<th>${label}</th>`);
      html += "</tr>";

      labels.forEach(actual => {
        html += `<tr><th>${actual}</th>`;
        labels.forEach(predicted => {
          const value = confusionMatrixData[actual]?.[predicted] || 0;
          html += `<td>${value}</td>`;
        });
        html += "</tr>";
      });

      html += "</table>";
      container.innerHTML = html;
    }
  </script>
</body>
</html>
