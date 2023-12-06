<wordlist-option-display-item class="wordlist-option-display-item">
    <div class="card-panel hover">
        <i class="material-icons material-clickable pull-right"
                onclick={opts.onRemove}>clear</i>
        <span>
            {opts.name}
        </span>
        <ui-checkbox
                if={opts.showCheckbox}
                id={"da-" + opts.name}
                inline={true}
                name={opts.name}
                disabled={opts.disabled}
                checked={opts.lowercase}
                on-change={opts.onCheckboxChange}
                label="A = a"/></ui-checkbox>
    </div>
    <script>
        require("./wordlist-option-display-item.scss")
    </script>
</wordlist-option-display-item>
