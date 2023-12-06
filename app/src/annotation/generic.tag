<generic class="card generic">
    <div class="row">
        <div class="col s10 m11">
            <span class="card-title truncate">{opts.data.label}</span>
        </div>
        <div class="col s2 m1 text-right">
            <button class="btn btn-flat btn-floating tooltipped"
                    onclick={close}
                    data-tooltip={_("closeCard")}>
                <i class="material-icons">close</i>
            </button>
        </div>
    </div>
    <div class="row mt-8">
        <div class="col s10">
            <ui-input ref="comment"
                  name="comment"
                  value={data.attr && data.attr.comment}
                  label={_("an.comment")}>
            </ui-input>
          </div>
          <div class="s2">
            <button class="btn btn-floating tooltipped"
                    onclick={saveComment}
                    data-tooltip={_("saveComment")}>
                <i class="material-icons">save</i>
            </button>
        </div>
    </div>
    <div class="row mt-8">
        <div class="col s12" style="margin-bottom: 1em;">
            <ui-checkbox name="enable_attributes"
                    on-change={toggleAttributes}
                    label-id="an.enableAttributes"
                    checked={enable_attributes}>
            </ui-checkbox>
        </div>
    </div>
    <table if={enable_attributes} class="attributes table material-table striped">
        <thead>
            <tr>
                <th>
                  {_("attribute")}
                </th>
                <th>{_("value")}</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <tr each={at, idx in label.attributes}>
                <td>
                  <span data-name={at.name}
                          hide={editAttrLabel[at.name]}
                          onclick={showInput.bind(this, "label")}
                          class="pointer">{at.label}

                  </span>
                  <i class="material-icons tiny color-blue-800 pointer"
                          data-name={at.name}
                          hide={editAttrLabel[at.name]}
                          onclick={showInput.bind(this, "label")}>edit
                  </i>
                  <ui-input name={at.name}
                          show={editAttrLabel[at.name]}
                          riot-value={at.label}
                          on-blur={updateLabel.bind(this, "label")}
                          on-submit={updateLabel.bind(this, "label")}
                          class="newLabelInput">
                  </ui-input>
                </td>
                <td>
                  <span data-name={at.name}
                          hide={editAttrValue[at.name]}
                          onclick={showInput.bind(this, "value")}
                          class="pointer">{at.value}
                  </span>
                  <i class="material-icons tiny color-blue-800 pointer"
                          data-name={at.name}
                          hide={editAttrValue[at.name]}
                          onclick={showInput.bind(this, "value")}>edit
                  </i>
                  <ui-input name={at.name}
                          show={editAttrValue[at.name]}
                          riot-value={at.value}
                          on-blur={updateLabel.bind(this, "value")}
                          on-submit={updateLabel.bind(this, "value")}
                          class="newLabelInput">
                  </ui-input>
                </td>
                <td class="actions">
                    <button class="btn btn-flat btn-floating tooltipped"
                            onclick={removeAttr}
                            data-tooltip={_("an.removeAttr")}>
                        <i class="material-icons">delete</i>
                    </button>
                </td>
            </tr>
            <tr>
                <td>
                    <ui-input ref="newAttr"
                          name="newAttr"
                          placeholder={_("an.newAttr")}
                          on-input={onNewAttr}
                          riot-value={newAttr}
                          class="newLabelInput">
                    </ui-input>
                </td>
                <td colspan="2">
                    <ui-input ref="newVal"
                          name="newVal"
                          placeholder={_("value")}
                          on-input={onNewAttr}
                          riot-value={newVal}
                          class="newLabelInput">
                    </ui-input>
                </td>
            </tr>
        </tbody>
    </table>
    <div if={enable_attributes} class="row center-align mt-2">
      <button class="btn btn-floating tooltipped {pulse: edited}"
              onclick={saveAttributes}
              data-tooltip={_("saveAttributes")}>
          <i class="material-icons">save</i>
      </button>
    </div>
    <div class="row mb-0 fs85">
        <div class="col s12">
            <p>{_("created")}:<em>{opts.data.created}</em>
            ({opts.data.creator}),
            {_("an.lastEdited")} <em>{opts.data.edited}</em>
            ({opts.data.editor})</em></p>
        </div>
    </div>

    <script>
        const {AnnotationStore} = require('annotation/annotstore.js')

        this.edited = false
        this.data = this.opts.data
        this.label = this.opts.data.data
        this.query = this.opts.query
        this.annot_tag = this.root.parentNode._tag
        if (!this.label.attributes) {
            this.label.attributes = []
        }
        this.enable_attributes = this.label.attributes && this.label.attributes.length || false
        this.newAttr = ""
        this.newVal = ""
        this.editAttrLabel = []
        this.editAttrValue = []

        showInput(attrType, e) {
            let name = e.item.at.name
            if (attrType == "label"){
                this.editAttrLabel[name] = true
            }
            else if (attrType == "value"){
                this.editAttrValue[name] = true
            }
            this.update()
            e.target.parentNode.querySelector('input').focus()
        }

        updateLabel(attrType, value, name, e) {
            let item = e.item.at

            if (attrType == "label"){
                this.editAttrLabel[name] = false
                item.label = value
            }
            else if (attrType == "value"){
                this.editAttrValue[name] = false
                item.value = value
            }
            this.edited = true
        }

        toggleAttributes(value, name, e) {
            this.enable_attributes = value
            this.update()
        }

        removeAttr(e) {
            this.label.attributes.splice(e.item.idx, 1)
            AnnotationStore.saveLabel(this.data)
        }

        onNewAttr(value, name) {
            this[name] = value
            this.edited = true
            this.update()
        }

        saveComment() {
          this.data.attr.comment = this.refs["comment"].getValue()
          AnnotationStore.saveLabel(this.data)
        }

        saveAttributes() {
            if (this.newAttr.length) {
                this.label.attributes.push({
                    "name": "attr_" + (this.label.attributes.length+1),
                    "label": this.newAttr,
                    "value": this.newVal
                })
                this.newAttr = ""
                this.newVal = ""
            }
            AnnotationStore.saveLabel(this.data)
        }

        close() {
            this.annot_tag.close_label()
        }

        labelSaved(labeldata) {
            SkE.showToast(_("labelSaved", [this.opts.data.label]), {duration: 8000})
            this.annot_tag.updatePatStr(labeldata)
            this.edited = false
            this.update()
        }

        labelSaveFailed() {
            this.edited = false
            SkE.showToast(_("errorHasOccured"), {duration: 8000})
            this.update()
        }

        this.on("mount", function() {
            AnnotationStore.on("ANNOTATION_LABEL_SAVED", this.labelSaved)
            AnnotationStore.on("ANNOTATION_LABEL_SAVE_FAILED", this.labelSaveFailed)
        })

        this.on("unmount", function () {
            AnnotationStore.off("ANNOTATION_LABEL_SAVED", this.labelSaved)
            AnnotationStore.off("ANNOTATION_LABEL_SAVE_FAILED", this.labelSaveFailed)
        })
    </script>
</generic>
