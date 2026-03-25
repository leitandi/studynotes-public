const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

// Configuration
const NUM_ROWS = 13;
const HORIZONTAL_MARGIN_PERCENT = 0.04; // 4% of viewport width on each side
const NUM_CHAINS = 20; // Number of independent circle chains
const BLIP_DURATION = 500; // Duration of circle appearance in ms
const CIRCLE_DIAMETER_MULTIPLIER = 1.5; // Circle diameter as multiple of row spacing
const WAIT_TIME_MIN_MULTIPLIER = 10; // Minimum wait time as multiple of blip duration
const WAIT_TIME_RANGE_MULTIPLIER = 5; // Random range added to wait time multiplier

// Animation state
let animationTime = 0;
let lastTimestamp = null;

// Circle chain states
let circleChains = [];

// Resize canvas to fill viewport
function resizeCanvas() {
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();

  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;

  // Reset transformation matrix before scaling to prevent accumulation
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.scale(dpr, dpr);
}

// Draw the snake pattern (crisp rendering)
function drawSnake() {
  // Disable image smoothing for crisp lines
  ctx.imageSmoothingEnabled = false;

  // Use display dimensions for calculations
  const displayWidth = canvas.getBoundingClientRect().width;
  const displayHeight = canvas.getBoundingClientRect().height;

  // Calculate horizontal margin based on viewport width
  const horizontalMargin = displayWidth * HORIZONTAL_MARGIN_PERCENT;

  // Create gradient from orange to pink (top to bottom)
  const gradient = ctx.createLinearGradient(0, 0, 0, displayHeight);
  gradient.addColorStop(0, "#ff6600"); // Orange at top
  gradient.addColorStop(1, "#ff1493"); // Pink at bottom

  ctx.strokeStyle = gradient;
  ctx.lineWidth = 6;
  ctx.lineCap = "round"; // Rounded caps
  ctx.lineJoin = "round"; // Rounded corners
  ctx.beginPath();

  // Calculate vertical spacing
  const verticalSpacing = displayHeight / (NUM_ROWS + 1);

  // Starting position
  let direction = "right";
  let x = horizontalMargin;
  let y = verticalSpacing;

  ctx.moveTo(x, y);

  for (let row = 0; row < NUM_ROWS; row++) {
    if (direction === "right") {
      // Draw to the right edge
      x = displayWidth - horizontalMargin;
      ctx.lineTo(x, y);

      // Move down if not last row
      if (row < NUM_ROWS - 1) {
        y += verticalSpacing;
        ctx.lineTo(x, y);
      }

      direction = "left";
    } else {
      // Draw to the left edge
      x = horizontalMargin;
      ctx.lineTo(x, y);

      // Move down if not last row
      if (row < NUM_ROWS - 1) {
        y += verticalSpacing;
        ctx.lineTo(x, y);
      }

      direction = "right";
    }
  }

  ctx.stroke();
}

// Initialize circle chains
function initCircleChains(currentTime = 0) {
  circleChains = [];

  const displayWidth = canvas.getBoundingClientRect().width;
  const displayHeight = canvas.getBoundingClientRect().height;

  const avgWaitTime =
    BLIP_DURATION *
    (WAIT_TIME_MIN_MULTIPLIER + WAIT_TIME_RANGE_MULTIPLIER / 2);
  const fullCycle = BLIP_DURATION + avgWaitTime;

  for (let i = 0; i < NUM_CHAINS; i++) {
    // Initialize as if already in steady state
    const randomPhase = Math.random() * fullCycle;

    if (randomPhase < BLIP_DURATION) {
      // Start mid-blip
      const x = Math.random() * displayWidth;
      const y = Math.random() * displayHeight;

      circleChains.push({
        x: x,
        y: y,
        opacity: 0,
        nextBlipTime: currentTime,
        blipStart: currentTime - randomPhase,
        blipDuration: BLIP_DURATION,
        color: getColorFromPosition(x, y),
      });
    } else {
      // Start waiting
      circleChains.push({
        opacity: 0,
        nextBlipTime: currentTime + randomPhase - BLIP_DURATION,
      });
    }
  }
}

// Get color based on position using x and y coordinates
function getColorFromPosition(x, y) {
  const yellowGreen = { r: 150, g: 255, b: 50 };
  const cyanBlue = { r: 0, g: 200, b: 255 };

  const displayWidth = canvas.getBoundingClientRect().width;
  const displayHeight = canvas.getBoundingClientRect().height;

  // Normalize x and y to 0-1 range
  const xWeight = x / displayWidth;
  const yWeight = y / displayHeight;

  // Use x-position to blend between the two colors
  const progress = xWeight;

  const r = Math.round(
    yellowGreen.r + (cyanBlue.r - yellowGreen.r) * progress
  );
  const g = Math.round(
    yellowGreen.g + (cyanBlue.g - yellowGreen.g) * progress
  );
  const b = Math.round(
    yellowGreen.b + (cyanBlue.b - yellowGreen.b) * progress
  );

  return { r, g, b };
}

// Draw circles
function drawCircles(time) {
  const displayWidth = canvas.getBoundingClientRect().width;
  const displayHeight = canvas.getBoundingClientRect().height;

  // Calculate circle radius based on vertical spacing
  const verticalSpacing = displayHeight / (NUM_ROWS + 1);
  const circleRadius = (verticalSpacing * CIRCLE_DIAMETER_MULTIPLIER) / 2;

  for (let i = 0; i < circleChains.length; i++) {
    const chain = circleChains[i];

    // Check if it's time to blip
    if (time >= chain.nextBlipTime) {
      // If we're starting a new blip
      if (chain.opacity === 0) {
        // Generate new random position
        chain.x = Math.random() * displayWidth;
        chain.y = Math.random() * displayHeight;

        // Calculate color based on position
        chain.color = getColorFromPosition(chain.x, chain.y);

        chain.blipStart = time;
        chain.blipDuration = BLIP_DURATION;
        chain.nextBlipTime =
          time +
          BLIP_DURATION *
            (WAIT_TIME_MIN_MULTIPLIER +
              Math.random() * WAIT_TIME_RANGE_MULTIPLIER);
      }
    }

    // Calculate current opacity based on blip progress
    if (chain.blipStart !== undefined) {
      const elapsed = time - chain.blipStart;
      if (elapsed < chain.blipDuration) {
        const progress = elapsed / chain.blipDuration;
        chain.opacity = Math.sin(progress * Math.PI) * 0.8;
      } else {
        chain.opacity = 0;
        chain.blipStart = undefined;
      }
    }

    // Draw circle only if visible
    if (chain.opacity > 0) {
      const c = chain.color;
      ctx.fillStyle = `rgba(${c.r}, ${c.g}, ${c.b}, ${chain.opacity})`;
      ctx.beginPath();
      ctx.arc(chain.x, chain.y, circleRadius, 0, Math.PI * 2);
      ctx.fill();
    }
  }
}

// Main animation loop
function animate(timestamp) {
  if (lastTimestamp === null) {
    lastTimestamp = timestamp;
  }
  animationTime += timestamp - lastTimestamp;
  lastTimestamp = timestamp;

  // Clear canvas (background gradient is in CSS)
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw snake
  drawSnake();

  // Draw circles
  drawCircles(animationTime);

  requestAnimationFrame(animate);
}

// Handle window resize
window.addEventListener("resize", () => {
  resizeCanvas();
  initCircleChains(animationTime);
});

// Initialize
resizeCanvas();
initCircleChains(0);
requestAnimationFrame(animate);

// ── Plotly dark-mode theming ──────────────────────────────────────────────────

// Store original figure data so we can re-theme on toggle
const _loadedFigures = {};

function _isDarkMode() {
  return document.documentElement.getAttribute('data-theme') === 'dark';
}

// Hardcoded colors in the figures that need swapping in dark mode
const _COLOR_MAP_DARK = {
  '#2a3f5f':              '#ddd',               // text / labels
  '#060611':              '#aaa',               // axis lines, markers, borders
  'rgba(255,255,255,0.8)':'rgba(30,30,45,0.92)',// legend background
};

// Recursively deep-clone an object, swapping dark colors for light ones (or back)
function _deepTheme(obj, isDark) {
  if (typeof obj === 'string') {
    if (!isDark) return obj; // light mode: use stored originals as-is
    const lo = obj.toLowerCase().replace(/\s/g, ''); // normalise spaces
    const mapped = _COLOR_MAP_DARK[lo];
    if (mapped) return mapped;
    return obj;
  }
  if (Array.isArray(obj)) return obj.map(v => _deepTheme(v, isDark));
  if (obj !== null && typeof obj === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(obj)) out[k] = _deepTheme(v, isDark);
    return out;
  }
  return obj;
}

// Apply theme to both layout and data, returning { layout, data }
function _applyPlotlyTheme(figure, isDark) {
  const layout = {
    ..._deepTheme(figure.layout, isDark),
    width: undefined,
    height: undefined,
    autosize: true,
  };
  const data = _deepTheme(figure.data, isDark);
  return { layout, data };
}

// Re-render all loaded Plotly figures with the current theme
function relayoutAllPlots() {
  const dark = _isDarkMode();
  Object.entries(_loadedFigures).forEach(([id, figure]) => {
    const el = document.getElementById(id);
    if (!el) return;
    const { layout, data } = _applyPlotlyTheme(figure, dark);
    Plotly.purge(el);
    Plotly.newPlot(el, data, layout, { responsive: true, displayModeBar: false });
  });
}

// Expose so the toggle button script can call it
window.relayoutAllPlots = relayoutAllPlots;

// ── Auto-load all Plotly figures ──────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  const plotlyFigures = document.querySelectorAll('.plotly-figure');

  plotlyFigures.forEach((div, index) => {
    const src = div.getAttribute('data-src');
    if (!src) return;

    // Generate unique ID if not present
    if (!div.id) {
      div.id = `plotly-figure-${index}`;
    }

    // Create wrapper for plot and caption
    const wrapper = document.createElement('div');
    wrapper.className = 'figure-wrapper';

    // Create plot container
    const plotContainer = document.createElement('div');
    plotContainer.className = 'plot-container figure-container';
    plotContainer.id = div.id;

    // Create caption if data-caption exists
    const caption = div.getAttribute('data-caption');
    const captionHtml = div.getAttribute('data-caption-html');
    if (caption || captionHtml) {
      const figcaption = document.createElement('figcaption');
      figcaption.className = 'figure-caption';
      if (captionHtml) {
        figcaption.innerHTML = captionHtml;
      } else {
        figcaption.textContent = caption;
      }
      wrapper.appendChild(plotContainer);
      wrapper.appendChild(figcaption);
    } else {
      wrapper.appendChild(plotContainer);
    }

    // Replace the original div with the wrapper
    div.parentNode.replaceChild(wrapper, div);

    fetch(src)
      .then(response => response.json())
      .then(figure => {
        // Store original figure for re-theming on toggle
        _loadedFigures[plotContainer.id] = figure;

        const { layout, data } = _applyPlotlyTheme(figure, _isDarkMode());

        Plotly.newPlot(plotContainer.id, data, layout, {
          responsive: true,
          displayModeBar: false,
        });
      })
      .catch(error => {
        console.error(`Error loading plot from ${src}:`, error);
        plotContainer.innerHTML = `<p style="color: red;">Error loading plot: ${src}</p>`;
      });
  });

  // Auto-load all PNG figures
  const pngFigures = document.querySelectorAll('.png-figure');

  pngFigures.forEach((div, index) => {
    const src = div.getAttribute('data-src');
    if (!src) return;

    // Generate unique ID if not present
    if (!div.id) {
      div.id = `png-figure-${index}`;
    }

    // Create wrapper for image and caption
    const wrapper = document.createElement('div');
    wrapper.className = 'figure-wrapper';

    // Create image container
    const imageContainer = document.createElement('div');
    imageContainer.className = 'image-container figure-container';
    imageContainer.id = div.id;

    // Create image element
    const img = document.createElement('img');
    img.src = src;
    img.alt = div.getAttribute('data-caption') || 'Figure';
    img.style.maxWidth = '100%';
    img.style.height = 'auto';
    img.style.display = 'block';
    img.style.margin = '0 auto';
    imageContainer.appendChild(img);

    // Create caption if data-caption exists
    const caption = div.getAttribute('data-caption');
    const captionHtml = div.getAttribute('data-caption-html');
    if (caption || captionHtml) {
      const figcaption = document.createElement('figcaption');
      figcaption.className = 'figure-caption';
      if (captionHtml) {
        figcaption.innerHTML = captionHtml;
      } else {
        figcaption.textContent = caption;
      }
      wrapper.appendChild(imageContainer);
      wrapper.appendChild(figcaption);
    } else {
      wrapper.appendChild(imageContainer);
    }

    // Replace the original div with the wrapper
    div.parentNode.replaceChild(wrapper, div);
  });

  // Handle window resize for Plotly figures
  window.addEventListener('resize', () => {
    const plotContainers = document.querySelectorAll('.plot-container');
    plotContainers.forEach((container) => {
      if (container.id) {
        Plotly.Plots.resize(container.id);
      }
    });
  });

  // Process figure references
  const figureRefs = document.querySelectorAll('a.fig-ref');
  const allFigureContainers = document.querySelectorAll('.figure-container');

  figureRefs.forEach((ref) => {
    const href = ref.getAttribute('href');
    if (!href || !href.startsWith('#')) return;

    const targetId = href.substring(1);

    // Find the index of the target figure (counting both plotly and PNG figures)
    const figureIndex = Array.from(allFigureContainers).findIndex(
      container => container.id === targetId
    );

    if (figureIndex !== -1) {
      ref.textContent = `Figure ${figureIndex + 1}`;
    }
  });
});
