$ ->
  $('#add_survey_form #type').data('pre', $(this).val());
  
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

    $(this).parent().find("." + previos_type).hide()
    $(this).parent().find("." + type).show()
    $(this).data("pre", type)

  ## add inputs to radio list
  $("#surveys").on "click", ".add_list_radio", (e) ->
    e.preventDefault()
    val = $(this).val()
    parent = $(this).parent().parent()

    how_many = $(parent).find(".list_radio_options").children().length/2

    if how_many < 6
      $(parent).find(".list_radio_options").append($("<input name='option#{how_many+1}'></input><br>"))
  
  ## reset survey clicked
  $("#add_survey_form input:reset").click ->
    $(".list_radio .list_radio_options").children().remove()

  ## add more survey
  $("#add_more").click (e) ->
    e.preventDefault()
    n = $("#surveys .survey").length
    if n < 3
      $("#surveys").append($("<div id='survey#{n+1}', class='survey'>#{$('#survey_template').html()}</div>"))
    else
      $("#add_survey_errors").attr("class", "error").html("too many surveys").fadeIn()


  ## add survey submited 
  $("#add_survey_form").submit (e) ->
    e.preventDefault()
    surveys = []
    name    = $(this).find("input[name=name]").val()

    $(this).find(".survey").each (i, el) ->
      obj = {}  
      obj.question = $(el).find("input[name=question]").val()
      obj.type     = $(el).find(".type").val()

      if obj.type is "list_radio"
        obj.option_count = $(el).find(".list_radio_options").children().length/2
        if obj.option_count > 0
          for i in [1..obj.option_count]
            obj["option" + i] = $(el).find(".list_radio_options input[name=option#{i}]").val()
      surveys.push(obj)

    $.post "/create/survey" , {name: name, surveys: surveys}, (r) ->
      if r.okay
        $("#add_survey_errors").html("survey added succesfully").attr("class", "success").fadeIn()
        $(".survey").remove()
        $("#add_survey_form input[name=name]").val("")
      else if r.errors?.length > 0
        $("#add_survey_errors").html(r.errors.join("<br>")).attr("class", "error").fadeIn()




