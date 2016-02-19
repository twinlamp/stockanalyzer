var highchart = function () {
  quotes = $('#chart-data').data('quotes')
  earnings = $('#chart-data').data('earnings')
  graph_max = $('#chart-data').data('graphmax')
  graph_min = $('#chart-data').data('graphmin')

  if (earnings == null) {
    $('#highchart').highcharts('StockChart', {
       chart: {
            alignTicks: false,
            height: 800,
            },
       yAxis: [{
            type: 'logarithmic',
            ceiling: graph_max*20,
            max: graph_max*20,
            min: graph_min*20,
            startOnTick: false,
            endOnTick: false,
            opposite: false
        }],
        series: [{
            name: "Price",
            data: quotes
        }]
    });
  } else {
    $('#highchart').highcharts('StockChart', {
       chart: {
            alignTicks: false,
            height: 800,
            },
       yAxis: [{
            type: 'logarithmic',
            ceiling: graph_max*20,
            max: graph_max*20,
            min: graph_min*20,
            startOnTick: false,
            endOnTick: false,
            opposite: false
        } , {
            type: 'logarithmic',
            ceiling: graph_max,
            max: graph_max,
            min: graph_min,
            startOnTick: false,
            endOnTick: false,
            opposite: true
        }],
       xAxis: {
            min: earnings[0][0] - 31536000000
        },
        series: [{
            name: "Price",
            data: quotes
        } , {
            name: "Earnings",
            data: earnings,
            yAxis: 1,
            type: 'column'
        }]
    });

  }
}

$(highchart);
$(function(){
  $('#chart-data').on('datachange', highchart)
});

