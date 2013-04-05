$ ->
  ## add default survey
  $("#surveys").append($("<div id='survey1', class='survey'>#{$('#survey_template').html()}</div>"))



  ## authenticate user
  $("#login_form").submit (e) ->
    e.preventDefault()
    user     = $(this).find("input[name=user]").val()
    password = $(this).find("input[name=password]").val()

    $.post "/admin", {user, password}, (res) ->
      if res.okay
        window.location.replace("/admin")
      else
        $("#login_errors").html(res.errors.join("<br>")).attr("class", "error").fadeIn()



  ## add survey clicked
  $("#add_survey_link").click (e) ->
    e.preventDefault()
    $("#add_survey").toggle()
    $("#add_more").toggle()



  ## type changed
  $("#surveys").on "change", ".type", ->
    previos_type = $(this).data("pre") or "yes_or_no"
    type = $(this).val()
    $(this).data("pre", type)

    $(this).parent().parent().find("." + previos_type).hide()
    $(this).parent().parent().find("." + type).show()



  ## reset survey clicked
  $("#add_survey_form input:reset").click ->
    $(".list_radio .list_radio_options").children().remove()
    $(".list_dropdown .list_dropdown_options").children().remove()


  ## add more survey
  $("#add_more").click (e) ->
    e.preventDefault()
    n = $("#surveys .survey").length
    if n < 3
      $("#surveys").append($("<div id='survey#{n+1}', class='survey'>#{$('#survey_template').html()}</div>"))
    else
      $("#add_survey_errors").attr("class", "error").html("too many surveys").fadeIn()

  

  ## vote_multiple label clicked
  $("#vote_multiple label").click (e) ->
    $("#vote_multiple input").trigger("click")



  ## add inputs to radio list
  $("#surveys").on "click", ".add_list_radio, .add_list_dropdown", (e) ->
    type = $(this).parent().parent().find(".type").data("pre")

    e.preventDefault()
    val = $(this).val()
    parent = $(this).parent().parent()

    how_many = $(parent).find(".#{type}_options").children().length/2

    if how_many < 6
      $(parent).find(".#{type}_options").append($("<input type='text', name='option#{how_many+1}'></input><br>"))
  


  ## add survey submited 
  $("#add_survey_form").submit (e) ->
    e.preventDefault()
    surveys       = []
    name          = $(this).find("input[name=name]").val()
    name          = $(this).find("input[name=name]").val()
    vote_multiple = $(this).find("input[name=vote_multiple]").is(":checked")

    $(this).find(".survey").each (i, el) ->
      obj = {}  
      obj.question = $(el).find("input[name=question]").val()
      obj.type     = $(el).find(".type").val()

      if obj.type is "list_radio" or obj.type is "list_dropdown"
        obj.option_count = $(el).find(".#{obj.type}_options").children().length/2
        if obj.option_count > 0
          for i in [1..obj.option_count]
            obj["option" + i] = $(el).find(".#{obj.type}_options input[name=option#{i}]").val()
      surveys.push(obj)

    $.post "/create/survey" , {name, surveys, vote_multiple}, (r) ->
      if r.okay
        $("#add_survey_errors").html("survey added succesfully").attr("class", "success").fadeIn()
        $(".survey").remove()
        $("#add_survey_form input[name=name]").val("")
      else if r.errors?.length > 0
        $("#add_survey_errors").html(r.errors.join("<br>")).attr("class", "error").fadeIn()


