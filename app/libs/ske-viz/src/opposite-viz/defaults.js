const defaultParams = {
  viz: {
    divId: 'viz-container',
    svgId: 'ske-viz-opposite',
    className: 'viz-opposite',
    width: 800,
    height: 500,
    margin: { top: 80, right: 50, bottom: 60, left: 50 },
    mainWordWidth: 60,
    animation: true,
    maxItems: undefined
  },
  tick: {
    number: 7
  },
  text: {
    show: true,
    scale: true,
    color: 'rgb(255, 255, 255)',
    size: [13, 25],
    mainWordSize: 25,
    font: 'Helvetica, Arial, sans-serif',
    mainWordColor: 'rgb(255, 255, 255)',
    mouseover: undefined,
    mouseout: undefined,
    mouseclick: undefined
  },
  circle: {
    show: true,
    // color: ['rgb(11, 158, 55)', 'rgb(149, 23, 171)'],
    // color: ['rgb(1, 133, 113)', 'rgb(166, 97, 26)'],
    color: ['rgb(4, 134, 150)', 'rgb(218, 148, 3)'],
    size: [0, 35],
    strokeWidth: 2,
    mouseover: undefined,
    mouseout: undefined,
    mouseclick: undefined
  },
  score: {
    // color: ['rgb(0, 163, 66)', 'rgb(140, 65, 172)'],
    // color: ['rgb(1, 133, 113)', 'rgb(166, 97, 26)'],
    color: ['rgb(13, 108, 120)', 'rgb(175, 128, 30)'],
    showNumbers: false,
    showText: [
      '← mostly with %w2',
      'equally frequently with %w1 and %w2',
      'mostly with %w1 →'
    ]
  },
  category: {
    showName: true,
    showItems: undefined
  },
  legend: {
    color: 'rgb(50, 50, 50)'
  }
};

export default defaultParams;
