document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const startBtn = document.getElementById('startBtn');
    const resetBtn = document.getElementById('resetBtn');
    const backBtn = document.getElementById('backBtn');
    const newAnalysisBtn = document.getElementById('newAnalysisBtn');
    const formSection = document.getElementById('formSection');
    const introSection = document.querySelector('.intro');
    const resultSection = document.getElementById('resultSection');
    const bohmTurnerForm = document.getElementById('bohmTurnerForm');
    const sliders = document.querySelectorAll('input[type="range"]');
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    // Initialize chart variable to store chart instance
    let starChart = null;
    
    // Event listeners for buttons
    startBtn.addEventListener('click', function() {
        introSection.classList.add('hidden');
        formSection.classList.remove('hidden');
    });
    
    resetBtn.addEventListener('click', function() {
        sliders.forEach(slider => {
            slider.value = 3;
            slider.nextElementSibling.nextElementSibling.textContent = '3';
        });
    });
    
    backBtn.addEventListener('click', function() {
        resultSection.classList.add('hidden');
        formSection.classList.remove('hidden');
    });
    
    newAnalysisBtn.addEventListener('click', function() {
        resultSection.classList.add('hidden');
        introSection.classList.remove('hidden');
        resetBtn.click();
        if (starChart) {
            starChart.destroy();
            starChart = null;
        }
    });
    
    // Update slider value displays
    sliders.forEach(slider => {
        slider.addEventListener('input', function() {
            this.nextElementSibling.nextElementSibling.textContent = this.value;
        });
    });
    
    // Tab functionality
    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons
            tabBtns.forEach(b => b.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');
            
            // Hide all tab contents
            tabContents.forEach(content => content.classList.remove('active'));
            // Show the corresponding tab content
            document.getElementById(this.dataset.tab).classList.add('active');
        });
    });
    
    // Form submission
    bohmTurnerForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get values from form
        const values = {
            personnel: parseFloat(document.getElementById('personnel').value),
            dynamism: parseFloat(document.getElementById('dynamism').value),
            culture: parseFloat(document.getElementById('culture').value),
            size: parseFloat(document.getElementById('size').value),
            criticality: parseFloat(document.getElementById('criticality').value)
        };
        
        // Process the results and show results section
        processResults(values);
        formSection.classList.add('hidden');
        resultSection.classList.remove('hidden');
    });
    
    // Process and display results
    function processResults(values) {
        // Calculate agile and prescriptive scores
        // Note: Lower values (1-2.5) favor agile, higher values (3.5-5) favor prescriptive
        const dimensions = Object.keys(values);
        
        let agileScore = 0;
        let prescriptiveScore = 0;
        
        dimensions.forEach(dim => {
            const value = values[dim];
            // Convert 1-5 scale to 0-1 for agile (inverted)
            const agileValue = (6 - value) / 4;  // 5 becomes 0.25, 1 becomes 1.25
            // Convert 1-5 scale to 0-1 for prescriptive
            const prescriptiveValue = value / 5;  // 1 becomes 0.2, 5 becomes 1
            
            agileScore += agileValue;
            prescriptiveScore += prescriptiveValue;
        });
        
        // Normalize scores to 0-100%
        agileScore = Math.round((agileScore / dimensions.length) * 100);
        prescriptiveScore = Math.round((prescriptiveScore / dimensions.length) * 100);
        
        // Display scores
        document.getElementById('agileScore').textContent = agileScore + '%';
        document.getElementById('prescriptiveScore').textContent = prescriptiveScore + '%';
        
        // Determine recommended approach
        const recommendedApproach = agileScore > prescriptiveScore ? 'Enfoque Ágil' : 'Enfoque Prescriptivo';
        document.getElementById('recommendedApproach').textContent = recommendedApproach;
        
        // Apply color styling based on recommendation
        document.getElementById('recommendedApproach').style.backgroundColor = 
            recommendedApproach === 'Enfoque Ágil' ? 'var(--agile)' : 'var(--prescriptive)';
        
        // Create star chart
        createStarChart(values);
    }
    
    // Create radar chart using Chart.js
    function createStarChart(values) {
        const ctx = document.getElementById('starChart').getContext('2d');
        
        // If chart already exists, destroy it
        if (starChart) {
            starChart.destroy();
        }
        
        // Convert values to array format for Chart.js
        const data = [
            values.personnel,
            values.dynamism,
            values.culture,
            values.size,
            values.criticality
        ];
        
        // Create new chart
        starChart = new Chart(ctx, {
            type: 'radar',
            data: {
                labels: ['Personal', 'Dinamismo', 'Cultura', 'Tamaño', 'Criticidad'],
                datasets: [{
                    label: 'Valores de Proyecto',
                    data: data,
                    backgroundColor: 'rgba(52, 152, 219, 0.3)',
                    borderColor: 'rgba(52, 152, 219, 1)',
                    pointBackgroundColor: 'rgba(52, 152, 219, 1)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(52, 152, 219, 1)'
                }]
            },
            options: {
                scales: {
                    r: {
                        angleLines: {
                            display: true
                        },
                        suggestedMin: 1,
                        suggestedMax: 5,
                        ticks: {
                            stepSize: 1
                        }
                    }
                },
                elements: {
                    line: {
                        tension: 0.2
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `Valor: ${context.raw}`;
                            }
                        }
                    }
                }
            }
        });
    }
});