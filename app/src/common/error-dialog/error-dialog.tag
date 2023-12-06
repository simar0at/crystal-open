<error-dialog class="error-dialog">
    <div class="black-text mt-8">
        <raw-html content={opts.message}></raw-html>
    </div>
    <details if={opts.detail} class="mt-8">
        <summary class="blue-text">
            {_("moreDetails")}
        </summary>
        <div class="black-text mt-2">
            <raw-html content={opts.detail}></raw-html>
        </div>
    </details>
</error-dialog>
