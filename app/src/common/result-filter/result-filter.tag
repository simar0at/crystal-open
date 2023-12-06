<result-filter class="result-filter">
    <filter-input ref="filter"
            class="mainFormField"
            disabled={store.isLoading || store.data.jobid}
            label-id="filter"
            size=20
            query={query}
            mode={mode}
            match-case={matchCase}
            hide-match-case={opts.hideMatchCase}
            suffix-icon="close"
            on-input={onInput}
            on-change={onFilterChange}
            on-submit={filter}
            on-suffix-icon-click={onCancel}>
    </filter-input>
    <button class="btn {disabled: store.isLoading || store.data.jobid}"
            onclick={filter}>
        <i class="material-icons">filter_list</i>
    </button>

    <script>
        this.mixin("feature-child")

        updateAttributes(){
            this.query = this.data.search_query
            this.mode = this.data.search_mode
            this.matchCase = this.data.search_matchCase
        }
        this.updateAttributes()

        onInput(query){
            this.query = query
        }

        onFilterChange(query, mode, matchCase){
            this.query = query
            this.mode = mode
            this.matchCase = matchCase
            this.refs.filter.update()
            this.filter()
        }

        filter(){
            this.store.changeFilter(this.query, this.mode, this.matchCase)
        }

        onCancel(){
            this.query = ""
            this.refs.filter.update()
            this.store.changeFilter("")
        }

        this.on("update", this.updateAttributes)

        this.on("mount")
    </script>
</result-filter>
