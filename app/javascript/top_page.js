class TopPageAnimation {
  constructor() {
    this.phases = {
      title: 500, subtitle: 1200, cloudsDisappear: 1200, clearSky: 2000,
      sun: 2200, sparkles: 2800, floatingElements: 3000,
      cta: 2600
    };
    this.elements = {
      titleSection: document.getElementById('title-section'),
      subtitle: document.getElementById('subtitle'),
      cloudsLayer: document.getElementById('clouds-layer'),
      clearSky: document.getElementById('clear-sky'),
      sun: document.getElementById('sun'),
      sparkles: document.querySelectorAll('[class*="sparkle-"]'),
      floatingElements: document.querySelectorAll('#floating-elements > div'),
      cta: document.getElementById('cta-wrap')
    };
  }

  start() {
    if (!this.elements.titleSection) return; // 他ページで実行されても安全に無視

    setTimeout(() => {
      this.elements.titleSection.style.opacity = '1';
      this.elements.titleSection.classList.add('animate-fade-in-up');
    }, this.phases.title);

    setTimeout(() => { this.elements.subtitle.style.opacity = '1'; }, this.phases.subtitle);
    setTimeout(() => { this.disappearClouds(); }, this.phases.cloudsDisappear);
    setTimeout(() => { this.elements.clearSky.style.opacity = '1'; }, this.phases.clearSky);
   setTimeout(() => {this.elements.sun.classList.add('sun-visible'); }, this.phases.sun);
   
    setTimeout(() => { this.showSparkles(); }, this.phases.sparkles);
    setTimeout(() => { this.showFloatingElements(); }, this.phases.floatingElements);
    setTimeout(() => { this.elements.cta.style.opacity = '1'; }, this.phases.cta);
  }

  disappearClouds() {
    Array.from(this.elements.cloudsLayer.children).forEach((cloud, i) => {
      setTimeout(() => { cloud.classList.add('animate-cloud-disappear'); }, i * 200);
    });
  }

  showSparkles() {
    this.elements.sparkles.forEach((sparkle, i) => {
      setTimeout(() => {
        sparkle.style.opacity = '1';
        sparkle.classList.add('animate-sparkle-glow');
      }, i * 400);
    });
  }

  showFloatingElements() {
    this.elements.floatingElements.forEach((el, i) => {
      setTimeout(() => { el.style.opacity = '0.8'; }, i * 300);
    });
  }
}

// Turboでも確実に走るように
document.addEventListener('turbo:load', () => {
  const top = new TopPageAnimation();
  top.start();
});