# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  # registering click event for list div
  $(document).on("click", ".list", -> 
    console.log this
    changeSelected(this)
    id = getId(this)
    getList(id, ""))

  if $(".list").length
    $(".list:first").click() 
  # registering click event for add tag
  # makes edit div with input visibile
  # hides add tag
  # puts input in focus
  $(document).on("click", ".addtag", ->
    this.style.display = "none"
    editTag = $(this).prev()[0]
    editTag.style.display  = "inline"
    input = $(editTag).children()[0]
    $(input).focus()
  )
  

  $(document).on("click", ".list-del", (e)->
    listId = $(this).parent().attr('id').substring(4)
    deleteList(listId) 
    e.stopPropagation()
  )

  $(document).on("click", ".remove", ->
    tag = $(this).parent()
    tagName = tag.attr("name")
    itemId = getItemIdFromTag(this)
    destroyTag(itemId, tagName)
  )

  $(document).on("click", ".destroy", ->
    item = $(this).parent()
    itemId  = $(item).attr("itemId")
    destroyItem(itemId)
  )

  $("#top-tag-filter").on("click", ".tag", ->
    listId = getListIdFromSelected()
    tagName = $(this).attr("name")
    changeSelectedTag(this)
    tag = if (tagName == 'All items') then "" else tagName
    console.log tag
    filterList(listId, tag)
  )
    
  $(document).on("change", ".check", ->
    console.log this.checked
    $(this).parent().parent().toggleClass "done" # toggle item done
    itemId = getItemIdFromTag(this)
    updateItem(itemId, this.checked)
  )
  # registering blur event for edittag
  # hides edit div with input
  # makes addTag div visible
  $(document).on("blur", ".edittag-input", ->
    hideEditAndShowAdd(this)
  )

  $(document).on("keyup", ".edittag-input", (e) ->
    if e.keyCode == 13
      itemId =  getItemIdFromTag(this)
      newTag = $(this).val()
      hideEditAndShowAdd(this) 
      postTag(itemId, newTag)
  )

  # creates a new list on enter in new list input
  $("#new-list").keyup (e) ->
    if e.keyCode == 13
      postList()
      $("#new-list").val("")

  # creates a new item on enter in new todo input
  $("#new-todo").keyup (e) ->
    if e.keyCode == 13
      postItem() if $(".list.selected").length
      $("#new-todo").val("")

updateItem = (itemId, checked) ->
  $.ajax '/items/'+itemId+'.js',
    type: 'PUT',
    data: {"item" : {"checked" : checked} }
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
 

deleteList = (listId) ->
  $.ajax '/lists/'+listId+'.js',
    type: 'DELETE',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

hideEditAndShowAdd = (input) ->
  $(input).val("")
  editDivToHide = $(input).parent()[0]
  editDivToHide.style.display = "none"
  addTag = $(editDivToHide).next()[0]
  addTag.style.display = "inline"

destroyItem = (itemId) ->
  $.ajax '/items/'+itemId+'.js',
    type: 'DELETE',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

destroyTag = (itemId, newTag) ->
  list_id = getListIdFromSelected()
  $.ajax '/items/'+itemId+'/tag.js',
    type: 'DELETE',
    data: {"name": newTag, "list_id" : list_id}
    error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"


postTag = (itemId, newTag) ->
  list_id = getListIdFromSelected()
  $.ajax '/items/'+itemId+'/tag.js',
    type: 'POST',
    data: {"name": newTag, "list_id" : list_id }
    error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"

postItem =  ->
  value = $("#new-todo").val()
  list_id = getListIdFromSelected()
  if /\S/.test value
    $.ajax '/items.js',
      type: 'POST',
      data: {"item": {"name" : value, "list_id" : list_id}},
      error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"

postList =  ->
  value = $("#new-list").val()
  if /\S/.test value
    $.ajax '/lists.js',
      type: 'POST',
      data: {"list": {"name" : value}},
      error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"

filterList = (id, tag) ->
  $.ajax '/lists/'+id+'/filter?tag='+tag,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}, #{errorThrown}, #{jqXHR}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"

getList = (id) ->
  $.ajax '/lists/'+id+'.js',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{textStatus}, #{errorThrown}, #{jqXHR}"
      success: (data, textStatus, jqXHR) ->
          console.log "Successful AJAX call"

getItemIdFromTag = (div) ->
  parentsArray = $(div).parentsUntil("#item-list")
  item = parentsArray[parentsArray.length-1]
  id = $(item).attr('itemId')

getListIdFromSelected = () ->
  selectedList = $(".list.selected")[0]
  getId(selectedList)

getId = (list) ->
  list.id.substring(4)

changeSelectedTag = (tag) ->
  console.log $("#top-tag-filter > .tag-list > .tag.selected").attr('class', 'tag')
  $(tag).attr('class', 'tag selected')

changeSelected = (list) ->
  $(".list.selected").attr('class', 'list')
  $(list).toggleClass('list list selected')


