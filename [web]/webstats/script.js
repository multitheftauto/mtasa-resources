const colors = [
  '#FF0000',
  '#00FF00',
  '#0000FF',
  '#FFFF00',
  '#00FFFF',
  '#FF00FF',
  '#FFFFFF',
  '#80FFFF',
  '#FF80FF',
  '#FFFF80',
  '#80FF00',
];
const autoRefreshFrequency = 5000; // ms

let chartEl;
let chartContainerEl;
let chart;
let chartTypeEl;
let chartTypeOptionEl;
let autoRefreshEl;
let autoRefreshInterval;
let now = [];

function init() {
  if (!chartEl) {
    chartEl = document.getElementById('chart');
    chartContainerEl = document.getElementById('chart-container');
    chartTypeEl = document.getElementById('chart-type');

    autoRefreshEl = document.getElementById('auto-refresh');
    autoRefreshEl.addEventListener('change', function () {
      if (autoRefreshInterval) clearInterval(autoRefreshInterval);
      if (!autoRefreshEl.checked) return;
      autoRefreshInterval = setInterval(updateChart, autoRefreshFrequency);
      updateChart();
    });
  }

  if (chart) chart.destroy();

  chartTypeOptionEl = chartTypeEl.selectedOptions[0];

  const isStacked = chartTypeOptionEl.dataset.stacked !== undefined;

  chart = new Chart(chartEl.getContext('2d'), {
    type: chartTypeEl.value,
    options: {
      scales: {
        xAxes: [{ stacked: isStacked }],
        yAxes: [
          {
            stacked: isStacked,
            ticks: {
              beginAtZero: true,
            },
          },
        ],
      },
      aspectRatio: chartContainerEl.offsetWidth / chartContainerEl.offsetHeight,
      // Disable animations
      animation: { duration: 0 },
      hover: { animationDuration: 0 },
      responsiveAnimationDuration: 0,
    },
  });

  updateChart();
}

function updateChart() {
  const statsRequired = Array.from(
    document.querySelectorAll('#datasets input:checked'),
  ).map(function (el) {
    return el.value;
  });

  if (!statsRequired) return;

  getRegisteredStats(function (registeredStats) {
    getCurrentStats(function (stats) {
      if (chartTypeOptionEl !== chartTypeEl.selectedOptions[0]) init();

      const isNow = chartTypeOptionEl.dataset.now !== undefined;

      if (isNow) {
        const color = statsRequired.map(function (_, index) {
          return colors[index % colors.length];
        });
        chart.data = {
          datasets: [
            {
              backgroundColor: color,
              borderColor: color,
              data: statsRequired.map(function (statRequired) {
                return stats.slice(-1)[0][statRequired];
              }),
              fill: false,
            },
          ],
          labels: statsRequired.map(function (statRequired) {
            return registeredStats[statRequired].name;
          }),
        };
      } else {
        chart.data = {
          datasets: statsRequired.map(function (statRequired, index) {
            const color = colors[index % colors.length];
            return {
              backgroundColor: color,
              borderColor: color,
              data: stats
                .map(function (stats) {
                  return stats[statRequired];
                })
                .flat(),
              fill: false,
              label: registeredStats[statRequired].name,
            };
          }),
          labels: stats.map(function (v) {
            return v.time;
          }),
        };
      }

      chart.update();
    });
  });
}

function toggleDatasets() {
  const datasets = document.getElementById('datasets');
  const toggleButton = document.getElementById('toggleButton');

  chartEl.width = '';
  chartEl.style.width = '';

  if (toggleButton.value === 'hide datasets') {
    datasets.style.display = 'none';
    toggleButton.value = 'show datasets';
  } else {
    datasets.style.display = 'block';
    toggleButton.value = 'hide datasets';
  }

  chart.resize();
}
