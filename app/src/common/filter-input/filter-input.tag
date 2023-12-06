<filter-input class="filter-input {opts.class} inline-block">
   <span ref="dropdown"
         class="dropdownBtn {disabled: opts.disabled || opts.modeDisabled}"
         data-target="filter_options_dropdown_{id}">
      <raw-html ref="dropDownIcon"
            content={modeList[mode]}></raw-html>
      <i class="material-icons">arrow_drop_down</i>
   </span>
   <ui-input ref="input"
         name="query"
         riot-value={query}
         size={opts.size}
         inline={opts.inline}
         label-id={opts.labelId}
         disabled={opts.disabled}
         autocomplete={false}
         no-blur-on-esc={true}
         suffix-icon={query ? "close" : "search"}
         on-input={onInput}
         on-suffix-icon-click={onSuffixIconClick}
         on-submit={onSubmit}></ui-input>
   <ul id="filter_options_dropdown_{id}"
         class="dropdown-content">
      <li each={svg, mode in modeList}
            class="t_{mode}">
         <a href="javascript:void(0);"
               onclick={onModeChange}>
            <raw-html content={svg}></raw-html>
            {capitalize(_(mode))}
         </a>
      </li>
      <li if={!opts.hideMatchCase}
            class="divider"
            tabindex="-1"></li>
      <li if={!opts.hideMatchCase}>
         <span>
            <ui-checkbox label={capitalize(_("matchCase"))}
                  name="matchCase"
                  checked={matchCase}
                  class="ml-1 mb-0"
                  on-change={onMatchCaseChange}></ui-checkbox>
         </span>
      </li>
   </ul>

   <script>
      require("./filter-input.scss")

      this.id = Math.round(Math.random() * 1000000)
      this.modeList = {
         containing: '<svg viewBox="0 0 24 24" fill="black" xmlns="http://www.w3.org/2000/svg">\
              <g transform="matrix(0, 1, -1, 0, 24, 0)">\
               <rect fill="none" height="24" width="24"/>\
               <g>\
                 <path d="M 8.086 7.875 L 12.086 3.885 L 16.086 7.875 L 13.086 7.875 L 13.086 15.885 L 13.071 15.885 L 13.071 16.963 L 16.071 16.963 L 12.071 20.953 L 8.071 16.963 L 11.071 16.963 L 11.071 8.953 L 11.086 8.953 L 11.086 7.875 Z"/>\
               </g>\
              </g>\
            </svg>',
         startingWith: '<svg viewBox="0 0 24 24" fill="black" xmlns="http://www.w3.org/2000/svg">\
              <g transform="matrix(0, 1, -1, 0, 24, 0)">\
               <rect fill="none" height="24" width="24"/>\
               <path d="M 11 6.99 L 11 15 L 13 15 L 13 6.99 L 16 6.99 L 12 3 L 8 6.99 L 11 6.99 Z"/>\
               <circle style="" transform="matrix(0, -1, 1, 0, -348.114136, 111.104637)" cx="91.105" cy="360.114" r="2.287"/>\
              </g>\
            </svg>',
         endingWith: '<svg viewBox="0 0 24 24" fill="black" xmlns="http://www.w3.org/2000/svg">\
              <g transform="matrix(0, 1, -1, 0, 24, 0)">\
               <rect fill="none" height="24" width="24"/>\
               <path d="M 11.029 14.21 L 11.029 22.22 L 13.029 22.22 L 13.029 14.21 L 16.029 14.21 L 12.029 10.22 L 8.029 14.21 L 11.029 14.21 Z"/>\
               <circle style="" transform="matrix(0, -1, 1, 0, -348.199738, 96.17955)" cx="91.105" cy="360.114" r="2.287"/>\
              </g>\
            </svg>',
         exactMatch: '<svg viewBox="0 0 24 24" fill="black" xmlns="http://www.w3.org/2000/svg">\
              <g id="svg_7" transform="matrix(0.045935, 0, 0, 0.045935, -12.304622, -4.632788)">\
               <path d="M 365.901 266.92 L 692.384 266.92 L 692.384 326.942 L 365.901 326.942 L 365.901 266.92 Z" id="svg_3" stroke-width="1.5"/>\
               <path d="M 365.834 397.246 L 692.317 397.246 L 692.317 457.268 L 365.834 457.268 L 365.834 397.246 Z" id="rect-1" stroke-width="1.5" />\
              </g>\
            </svg>',
         matchingRegex: '<svg viewBox="0 0 24 24" fill="black" xmlns="http://www.w3.org/2000/svg">\
              <g transform="matrix(0, 1, -1, 0, 24, 0)">\
               <rect fill="none" height="24" width="24"/>\
               <g>\
                 <path d="M 10.418 15.136 L 10.418 14.846 C 10.418 13.813 10.555 12.853 10.828 11.966 C 11.108 11.079 11.488 10.326 11.968 9.706 C 12.455 9.086 12.995 8.656 13.588 8.416 L 13.998 9.466 C 13.405 9.899 12.945 10.579 12.618 11.506 C 12.298 12.433 12.135 13.516 12.128 14.756 L 12.128 15.036 C 12.128 16.309 12.288 17.416 12.608 18.356 C 12.935 19.289 13.398 19.973 13.998 20.406 L 13.588 21.466 C 13.001 21.226 12.461 20.793 11.968 20.166 C 11.475 19.539 11.095 18.789 10.828 17.916 C 10.561 17.043 10.425 16.116 10.418 15.136 ZM 16.167 16.526 C 16.507 16.526 16.791 16.629 17.017 16.836 C 17.237 17.036 17.347 17.293 17.347 17.606 C 17.347 17.919 17.237 18.176 17.017 18.376 C 16.791 18.576 16.507 18.676 16.167 18.676 C 15.827 18.676 15.547 18.576 15.327 18.376 C 15.101 18.169 14.987 17.913 14.987 17.606 C 14.987 17.293 15.101 17.036 15.327 16.836 C 15.547 16.629 15.827 16.526 16.167 16.526 ZM 18.967 14.266 L 20.407 12.536 L 18.347 11.966 L 18.757 10.766 L 20.777 11.596 L 20.617 9.366 L 21.977 9.366 L 21.817 11.646 L 23.777 10.826 L 24.197 12.046 L 22.097 12.616 L 23.487 14.296 L 22.387 15.046 L 21.227 13.176 L 20.067 14.986 L 18.967 14.266 ZM 28.189 14.746 L 28.189 15.026 C 28.189 16.019 28.046 16.963 27.759 17.856 C 27.466 18.749 27.063 19.516 26.549 20.156 C 26.036 20.796 25.479 21.233 24.879 21.466 L 24.469 20.406 C 25.063 19.966 25.519 19.289 25.839 18.376 C 26.159 17.463 26.326 16.413 26.339 15.226 L 26.339 14.836 C 26.339 13.563 26.176 12.459 25.849 11.526 C 25.529 10.586 25.069 9.899 24.469 9.466 L 24.879 8.416 C 25.473 8.643 26.023 9.073 26.529 9.706 C 27.043 10.333 27.446 11.086 27.739 11.966 C 28.033 12.853 28.183 13.779 28.189 14.746 Z" transform="matrix(0, -1, 1, 0, -2.046875, 31.2265625)"/>\
               </g>\
              </g>\
            </svg>'
      }

      updateAttributes(){
         this.query = this.opts.query
         this.mode = this.opts.mode || "containing"
         this.matchCase = this.opts.matchCase
      }
      this.updateAttributes()

      onInput(value){
         this.query = value
         this.refs.input.update({suffixIcon: this.query ? "close" : "search"})
         isFun(this.opts.onInput) && this.opts.onInput(value, this.opts.name)
      }

      onMatchCaseChange(value){
         this.matchCase = value
         this.opts.onChange(this.query, this.mode, this.matchCase)
      }

      onModeChange(evt){
         evt.preventUpdate = true
         this.mode = evt.item.mode
         this.refs.dropDownIcon.update({content: this.modeList[this.mode]})
         this.opts.onChange(this.query, this.mode, this.matchCase)
      }

      onSubmit(){
         this.opts.onChange(this.query, this.mode, this.matchCase)
      }

      onSuffixIconClick(){
         this.query && this.opts.onChange("", this.mode, this.matchCase)
         this.update()
      }

      initDropdown(){
         $(this.refs.dropdown).dropdown({
            constrainWidth: false,
            coverTrigger: false
         })
      }

      this.on("update", this.updateAttributes)

      this.on("mount", () => {
         $(".ui-input", this.root).prepend($(this.refs.dropdown))
         this.initDropdown()
      })
   </script>
</filter-input>
