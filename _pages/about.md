---
permalink: /
title: "About Me"
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---

Hi, I'm Haoshuai(Henry) Zhou. I'm currently the Algo and Research Audiology Team Lead at Orka and I hold a Master's degree in Electrical Engineering from Caltech. I'm passionate about using AI to solve real-world problems, and I'm also interested in using mathematical tools to explain AI.

Here, I'll be sharing my thoughts on AI, and I hope you find them interesting!

## Selected Publications

**Intrusive Intelligibility Prediction with ASR Encoders**  
Interspeech 2025 Workshop, 1st place in 3rd Clarity Prediction Challenge  
I led the team, guided technical direction, and coordinated the research efforts that resulted in this winning submission.  
[Paper](https://www.isca-archive.org/clarity_2025/yu25_clarity.pdf)

**No Audiogram: Leveraging Existing Scores for Personalized Speech Intelligibility Prediction**  
Interspeech 2025 Oral  
First author. Initiated the research idea, conducted the experiments, and wrote the paper.  
[Paper](https://www.isca-archive.org/interspeech_2025/zhou25g_interspeech.pdf)

**Unveiling the Best Practices for Applying Speech Foundation Models to Speech Intelligibility Prediction for Hearing-Impaired People**  
WASPAA 2025 Oral (Best Paper Candidate)  
First author. Initiated the research idea, conducted the experiments, and wrote the paper.  
[Paper](https://arxiv.org/abs/2505.08215)

## Blog Posts

For more thoughts and ideas, check out the [Blog Posts](/year-archive/) section. There, I write about speech foundation models, continual learning, and the occasional fun experiment.

<div id="visitor-section" style="max-width: 680px; margin: 2em auto 0;">
  <h3 class="archive__subtitle" style="text-align: center;">Visitors</h3>
  <div id="visitor-map" style="width: 100%; height: 360px;"></div>
  <p id="visitor-count" style="text-align: center; font-size: 1.05em; color: #777; margin-top: 0.75em;"></p>
</div>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/css/jsvectormap.min.css">
<script src="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/js/jsvectormap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/maps/world.js"></script>
<script>
  (function () {
    fetch('/assets/data/visitor-locations.json?_cache=' + (new Date().getTime()))
      .then(function (r) { if (!r.ok) { throw new Error('no data'); } return r.json(); })
      .then(function (data) {
        var values = {};
        var total = 0;
        var countries = 0;
        (data.regions || []).forEach(function (x) {
          if (!x.code) { return; }
          values[String(x.code).toUpperCase()] = x.count;
          total += x.count;
          countries += 1;
        });
        var countEl = document.getElementById('visitor-count');
        if (countEl) {
          countEl.textContent = total > 0
            ? (total.toLocaleString() + ' visits from ' + countries + ' ' + (countries === 1 ? 'country' : 'countries'))
            : 'Visitor data is syncing…';
        }
        if (typeof jsVectorMap === 'undefined') { return; }
        new jsVectorMap({
          selector: '#visitor-map',
          map: 'world',
          zoomButtons: false,
          backgroundColor: 'transparent',
          regionStyle: { initial: { fill: '#e8e8e8', stroke: '#ffffff', strokeWidth: 0.4 } },
          series: { regions: [{ attribute: 'fill', scale: ['#cfe8ff', '#08519c'], normalizeFunction: 'polynomial', values: values }] },
          onRegionTooltipShow: function (event, tooltip, code) {
            var c = values[code] || 0;
            tooltip.text(tooltip.text() + ': ' + c + (c === 1 ? ' visit' : ' visits'), true);
          }
        });
      })
      .catch(function () {
        var wrap = document.getElementById('visitor-section');
        if (wrap) { wrap.style.display = 'none'; }
      });
  })();
</script>
