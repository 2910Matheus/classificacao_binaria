// Caminho do modelo exportado do Teachable Machine
const URL = "./my_model/";

// Variáveis globais
let model, webcam, ctx, labelContainer, maxPredictions;
let lastTimestamp = performance.now();  // Para cálculo de FPS
let animationId;
let threshold = 0.9; // Limite de confiança mínimo

// Função que inicializa o modelo e a webcam
async function init() {
    document.getElementById("status").textContent = "Carregando modelo...";

    // Caminhos dos arquivos do modelo
    const modelURL = URL + "model.json";
    const metadataURL = URL + "metadata.json";

    // Carrega o modelo e o número de classes
    model = await tmPose.load(modelURL, metadataURL);
    maxPredictions = model.getTotalClasses();

    // Configuração da webcam
    const size = 200;
    const flip = true;  // Espelha horizontalmente a imagem
    webcam = new tmPose.Webcam(size, size, flip);
    await webcam.setup();  // Pede permissão da câmera
    await webcam.play();   // Inicia a câmera
    animationId = window.requestAnimationFrame(loop);  // Inicia o loop

    // Configura o canvas
    const canvas = document.getElementById("canvas");
    canvas.width = size;
    canvas.height = size;
    ctx = canvas.getContext("2d");

    // Prepara os rótulos de predição
    labelContainer = document.getElementById("label-container");
    labelContainer.innerHTML = "";
    for (let i = 0; i < maxPredictions; i++) {
    labelContainer.appendChild(document.createElement("div"));
    }

    // Atualiza interface
    document.getElementById("loader").style.display = "none";
    document.getElementById("status").textContent = "Detectando...";
}

// Função para parar a câmera e a animação
function stopWebcam() {
    if (webcam && webcam.stop) {
    webcam.stop();
    document.getElementById("status").textContent = "Parado";
    cancelAnimationFrame(animationId); // Para o loop
    }
}

// Loop de detecção contínua
async function loop(timestamp) {
    // Calcula FPS
    const delta = (timestamp - lastTimestamp) / 1000;
    const fps = (1 / delta).toFixed(1);
    lastTimestamp = timestamp;
    document.getElementById("fps").textContent = fps;

    // Atualiza frame e faz predição
    webcam.update();
    await predict();

    // Continua o loop
    animationId = window.requestAnimationFrame(loop);
}

// Realiza a predição com o modelo
async function predict() {
    // Estima a pose atual da imagem
    const { pose, posenetOutput } = await model.estimatePose(webcam.canvas);

    // Obtém predições com base na pose
    const prediction = await model.predict(posenetOutput);

    // Encontra a classe com maior confiança
    let topPrediction = prediction.reduce((max, p) => p.probability > max.probability ? p : max, prediction[0]);

    // Se a confiança for alta o suficiente, pode-se executar uma ação
    if (topPrediction.probability >= threshold) {
    const predicted = topPrediction.className;
    }

    // Atualiza a interface com as probabilidades
    for (let i = 0; i < maxPredictions; i++) {
    const classPrediction = prediction[i].className + ": " + prediction[i].probability.toFixed(2);
    labelContainer.childNodes[i].innerHTML = classPrediction;
    }

    // Desenha a pose estimada no canvas
    drawPose(pose);
}

// Desenha os pontos da pose no canvas
function drawPose(pose) {
    if (webcam.canvas) {
    ctx.drawImage(webcam.canvas, 0, 0); // Mostra o frame atual
    if (pose) {
        const minPartConfidence = 0.5;
        tmPose.drawKeypoints(pose.keypoints, minPartConfidence, ctx); // Pontos
        tmPose.drawSkeleton(pose.keypoints, minPartConfidence, ctx); // Conexões
    }
    }
}

// Alterna entre tema escuro e claro
function toggleTheme() {
    document.body.classList.toggle("light");
}

  const loader = document.getElementById('loader');
  const baseText = "Carregando câmera";
  let dotCount = 0;

  setInterval(() => {
    dotCount = (dotCount + 1) % 4; 
    let dots = '.'.repeat(dotCount);
    loader.textContent = baseText + dots;
  }, 1000); // Definir tempo