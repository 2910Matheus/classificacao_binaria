# 🧠 Detecção Binária com Teachable Machine

Este projeto é uma aplicação web interativa que utiliza **Teachable Machine** e **TensorFlow.js** para realizar detecção binária em tempo real pela webcam. Ele inclui uma interface elegante com troca de temas.

## 🚀 Funcionalidades

- 🎥 Captura de vídeo em tempo real via webcam
- 🌗 Alternância entre tema claro e escuro
- ⏱️ Indicador de FPS e status da detecção
- 📱 Design responsivo para dispositivos móveis

## 📁 Estrutura do Projeto

```
.
├── index.html
├── my_model/
│   ├── model.json
│   └── metadata.json
└── README.md
```

> A pasta `my_model/` deve conter os arquivos exportados do seu modelo treinado na Teachable Machine (JSONs de modelo e metadados).

## 🛠️ Tecnologias Utilizadas

- HTML5 + CSS3 (com animações e responsividade)
- JavaScript puro (Vanilla JS)
- [TensorFlow.js](https://www.tensorflow.org/js)
- [Teachable Machine Pose Library](https://teachablemachine.withgoogle.com/train/pose)

## 📦 Como Usar

1. Clone ou baixe este repositório:
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   ```

2. Adicione sua pasta `my_model` com os arquivos exportados do Teachable Machine.

3. Abra o arquivo `index.html` em seu navegador (não precisa de servidor).

4. Clique em `▶️ Iniciar detecção` para começar a usar.

## 📸 Capturas de Tela

A seguir, algumas imagens da interface da aplicação de detecção binária em tempo real:

### 🖥️ Interface principal
Esta é a tela inicial do sistema. Ao abrir o site, a câmera começa a carregar automaticamente. O usuário pode iniciar ou parar a detecção, e também alternar entre o tema claro e escuro.

![Interface Principal](./.png)

- **Iniciar detecção:** ativa a webcam e o modelo para começar a classificar.
- **Parar detecção:** pausa o funcionamento da IA.
- **Mudar tema:** alterna entre visual escuro e claro para conforto visual.

---

### 📊 Exibição de Status e FPS
Durante a detecção, é exibido em tempo real o **status da aplicação** e a **quantidade de quadros por segundo (FPS)** processados pelo modelo.

![Status e FPS](./.png)

- **Status:** mostra se a detecção está ativa ou aguardando.
- **FPS:** indica o desempenho da análise em tempo real.


## 📌 Requisitos

- Navegador moderno com suporte a webcam
- Permissão para acessar a câmera
- Conexão com a internet (para carregar TensorFlow.js via CDN)

## 📄 Licença

Este projeto é livre para uso educacional e pessoal. Você pode adaptá-lo conforme sua necessidade.

## 🙋‍♂️ Autor

Feito para um trabalho da faculdade por [Matheus Maia](https://github.com/2910matheus)
