<vis-icon class="vis-icon {pointer: isFun(opts.onClick)}">
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
           width="32px" height="32px" viewBox="0 0 122.719 122.721" enable-background="new 0 0 122.719 122.721"
           shape-rendering="inherit" xml:space="preserve" onclick={onClick} class={active: opts.isActive()}>
    	<circle cx="60.892"  cy="60.096"  r="14.972" id="c0" />
    	<circle cx="60.891"  cy="22.297"  r="10.334" id="c1" />
    	<circle cx="60.891"  cy="100.964" r="10.334" id="c2" />
    	<circle cx="22.156"  cy="60.096"  r="10.334" id="c3" />
    	<circle cx="100.489" cy="60.096"  r="10.333" id="c4" />
    	<circle cx="90.156"  cy="32.631"  r="10.334" id="c5" />
    	<circle cx="90.156"  cy="88.464"  r="10.334" id="c6" />
    	<circle cx="33.823"  cy="88.464"  r="10.333" id="c7" />
    	<circle cx="33.823"  cy="32.631"  r="10.333" id="c8" />
    </svg>

    <script>
        require('./vis-icon.scss')

        onClick() {
            isFun(opts.onClick) && opts.onClick()
        }
    </script>
</vis-icon>
