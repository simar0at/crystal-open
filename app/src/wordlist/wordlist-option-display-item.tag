<wordlist-option-display-item class="wordlist-option-display-item">
    <div class="card-panel hover">
        <i class="material-icons material-clickable pull-right" onclick={onRemove}>clear</i>
        <span>
            {opts.name}
        </span>
        <ui-checkbox
                if={opts.showCheckbox}
                id={"da-" + opts.name}
                inline={true}
                disabled={opts.disabled}
                checked={opts.lowercase}
                on-change={onCheckboxChange}
                label="A = a"/></ui-checkbox>
    </div>
    <script>
        require("./wordlist-option-display-item.scss")

        onRemove(){
            this.opts.onRemove(this.opts.name)
        }

        onCheckboxChange(checked){
            this.opts.onCheckboxChange(this.opts.name, checked)
        }
    </script>
</wordlist-option-display-item>
