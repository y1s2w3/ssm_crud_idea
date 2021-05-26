<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" isELIgnored="false" %>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>员工列表</title>
  <%
    pageContext.setAttribute("app_path", request.getContextPath());
  %>
  <!-- 引入 JQuery 脚本文件 -->
  <script type="text/javascript"
          src="${ app_path }/static/js/jquery-1.12.4.min.js"></script>
  <!-- 引入 bootstrap css 样式 -->
  <link rel="stylesheet"
        href="${ app_path }/static/bootstrap-3.4.1-dist/css/bootstrap.min.css">
  <!-- 引入 bootstrap js 脚本 -->
  <script type="text/javascript"
          src="${ app_path }/static/bootstrap-3.4.1-dist/js/bootstrap.min.js"></script>
  <script type="text/javascript">
    // 保存总记录数和当前页码，分别方便跳转到最后一页和当前页码
    var totalRecord, currentPage;

    // 页面加载完成后直接发送一个 Ajax 请求，获取分页数据
    $(function() {
      // 显示第一页数据
      to_page(1);

      // 给新增按钮绑定单击事件
      $("#emp_add_modal_btn").click(function() {
        // 清除表单数据（表单完整重置（表单的数据，表单的样式））
        reset_form("#empAddModal form");
        // 发送 Ajax 请求，获取部门名，加入到模态框中
        getDepts("#empAddModal select");
        // 弹出模态框
        $("#empAddModal").modal({
          // 设置是否点击关闭模态框
          backdrop : "static"
        });
      });

      // 给员工添加模态框关闭按钮绑定单击事件
      $("#emp_add_modal_close_btn").click(function() {
        return confirm("是否关闭当前员工添加模态框？")
      });

      // 给提交按钮绑定单击事件(保存员工)
      $("#emp_add_modal_submit_btn").click(function() {
        // 如果此时表单中有错误信息，则阻止提交
        //alert($("#email_update_input").parent().hasClass("has-error"));
        if($("#empName_add_input").parent().hasClass("has-error")) {
          return false;
        }
        if($("#email_add_input").parent().hasClass("has-error")) {
          return false;
        }
        // 1.校验提交给服务器的数据的合法性
        // (1) 前端校验
        // 验证员工名的合法性
        if( !empName_validate("#empName_add_input") ) {
          return false;
        };
        // 验证邮箱的合法性
        if( !email_validate("#email_add_input") ) {
          return false;
        }
        // (2)后端校验
        var empNameAjaxValidate = $(this).attr("ajax-empName-validate");
        if (empNameAjaxValidate == "fail") {
          return false;
        }
        var emailAjaxValidate = $(this).attr("ajax-email-validate");
        if (emailAjaxValidate == "fail") {
          return false;
        }
        // 发送提交的 Ajax 请求
        //alert($("#empAddModal form").serialize());
        $.ajax({
          url:"${app_path}/addEmp",
          type:"POST",
          data:$("#empAddModal form").serialize(),
          success:function(result){
            // 添加成功
            if(result.code == "100") {
              //1.关闭模态框
              $("#empAddModal").modal("hide");
              //2.跳转到最后一页
              //alert(totalRecord + 1);
              to_page(totalRecord + 1);
            } else if (result.code == "200") {
              //alert(result.extend.errorFieldMap);
              var errorFieldMap = result.extend.errorFieldMap;
              if(undefined != errorFieldMap) {
                // 显示失败信息
                //console.log(result.extend.errorFieldMap);
                //alert(result.extend.errorFieldMap.email);
                //alert(result.extend.errorFieldMap.empName);
                if(undefined != errorFieldMap.email) {
                  // 显示邮箱错误信息
                  show_validate_msg("#email_add_input", "fail", errorFieldMap.email);
                }
                if(undefined != errorFieldMap.empName) {
                  // 显示员工名错误信息
                  show_validate_msg("#empName_add_input", "fail", errorFieldMap.empName);
                }
              }
            }
          }
        });
      });

      // 给所有的编辑按钮绑定单击事件
      // 这是在按钮创建之前绑定了单击事件，因此未绑定成功
      /* $(".edit_btn").click(function() {
          alert("edit");
      }); */
      $(document).on("click", ".edit_btn", function() {
        //alert("edit");
        // 从表格中获取当前修改员工信息，加入到模态框中
        //var empId = $(this).parent().parent().children("td").eq(0).text();
        //var empName = $(this).parent().parent().children("td").eq(1).text();
        //var email = $(this).parent().parent().children("td").eq(2).text();
        //var gender = $(this).parent().parent().children("td").eq(3).text();
        //var deptName = $(this).parent().parent().children("td").eq(4).text();
        // 设置模态框中的员工信息
        //$("#empName_update_input").val(empName);
        //$("#email_update_input").val(email);
        //$("#gender_update_input").val(gender);
        //$("#deptName_update_input").val(deptName);
        // 清除表单数据（表单完整重置（表单的数据，表单的样式））
        reset_form("#empEditModal form");
        // 发送 Ajax 请求，获取部门名，加入到模态框中
        getDepts("#empEditModal select");
        // 发送 Ajax 请求，获取修改员工的信息，加入到模态框中
        getEmpById($(this).attr("edit-empId"));
        // 将当前操作的员工的编号信息保存到员工修改模态框中的更新按钮上
        $("#emp_update_modal_submit_btn").attr("edit-empId", $(this).attr("edit-empId"));
        // 将当前操作的员工编号信息保存到员工修改模态框中的邮箱输入框上
        $("#email_update_input").attr("edit-empId", $(this).attr("edit-empId"));
        // 弹出模态框
        $("#empEditModal").modal({
          backdrop: "static"
        });
      });

      // 给员工修改模态框的关闭按钮绑定单击事件
      $("#emp_update_modal_close_btn").click(function() {
        return confirm("是否关闭当前员工修改模态框？")
      });

      // 给更新按钮绑定单击事件，修改员工
      $("#emp_update_modal_submit_btn").click(function() {
        // 如果此时表单中邮箱有错误信息，则阻止提交
        //alert($("#email_update_input").parent().hasClass("has-error"));
        if($("#email_update_input").parent().hasClass("has-error")) {
          return false;
        }
        // 前端验证邮箱是否合法
        if( !email_validate("#email_update_input") ) {
          return false;
        }
        // 后端验证邮箱是否可用
        var emailAjaxValidate = $(this).attr("ajax-email-validate");
        if(emailAjaxValidate == "fail") {
          alert(false);
          return false;
        }
        // 获取当前正在修改员工的编号
        // 不优雅，用户可以通过修改 html 中的 id 来修改其他的员工
        var empId = $(this).attr("edit-empId");

        //alert($("#empEditModal form").serialize());

        // 2.发送 Ajax 请求，保存员工信息
        $.ajax({
          // 发送 PUT 请求的第一种方式：
          //url: "${app_path}/updateEmp/" + empId,
          //data: $("#empEditModal form").serialize() + "&_method=PUT",
          //type: "POST",
          // 发送 PUT 请求的第二种方式：需要在 web.xml 配置 FormContextFilter
          url: "${app_path}/updateEmp/" + empId,
          data: $("#empEditModal form").serialize(),
          type: "PUT",
          success: function(result) {
            //console.log(result);
            // 添加成功
            if(result.code == "100") {
              //1.关闭模态框
              $("#empEditModal").modal("hide");
              //2.跳转到当前页面
              to_page(currentPage);
            } else if (result.code == "200") {
              //alert(result.extend.errorFieldMap);
              var errorFieldMap = result.extend.errorFieldMap;
              if(undefined != errorFieldMap) {
                // 显示失败信息
                //console.log(result.extend.errorFieldMap);
                //alert(result.extend.errorFieldMap.email);
                //alert(result.extend.errorFieldMap.empName);
                if(undefined != errorFieldMap.email) {
                  // 显示邮箱错误信息
                  show_validate_msg("#email_update_input", "fail", errorFieldMap.email);
                }
                if(undefined != errorFieldMap.empName) {
                  // 显示员工名错误信息
                  show_validate_msg("#empName_update_input", "fail", errorFieldMap.empName);
                }
              }
            }
          }
        });
      });

      // 给员工邮箱修改输入框绑定 change 事件
      $("#email_update_input").change(function() {
        // 发送 Ajax 请求之前，首先进行前端校验
        if(!email_validate("#email_update_input")) {
          return false;
        }
        // 发送 Ajax 请求，校验邮箱是否已存在
        $.ajax({
          url: "${app_path}/checkEmailWithId/" + $(this).attr("edit-empId"),
          data: "email=" + $(this).val().trim(),
          type: "GET",
          success: function(result) {
            if(result.code == "100") {
              show_validate_msg("#email_update_input", "success", "邮箱名可用!");
              // 给员工保存按钮添加一个自定义属性，用来表示邮箱名校验成功或失败信息
              $("#emp_update_modal_submit_btn").attr("ajax-email-validate", "success");
            } else if (result.code == "200") {
              show_validate_msg("#email_update_input", "fail", result.extend.va_msg);
              $("#emp_update_modal_submit_btn").attr("ajax-email-validate", "fail");
            }
          }
        });
      });

      // 给员工邮箱添加输入框绑定 change 事件
      $("#email_add_input").change(function() {
        // 发送 Ajax 请求之前，首先进行前端校验
        if(!email_validate("#email_add_input")) {
          return false;
        }
        // 发送 Ajax 请求，校验邮箱是否已存在
        $.ajax({
          url: "${app_path}/checkEmail",
          data: "email=" + $(this).val().trim(),
          type: "GET",
          success: function(result) {
            if(result.code == "100") {
              show_validate_msg("#email_add_input", "success", "邮箱名可用!");
              // 给员工保存按钮添加一个自定义属性，用来表示邮箱校验成功或失败信息
              $("#emp_add_modal_submit_btn").attr("ajax-email-validate", "success");
            } else if (result.code == "200") {
              show_validate_msg("#email_add_input", "fail", result.extend.va_msg);
              $("#emp_add_modal_submit_btn").attr("ajax-email-validate", "fail");
            }
          }
        });
      });

      // 给员工姓名输入框绑定 change 事件
      $("#empName_add_input").change(function() {
        // 发送 Ajax 请求之前，首先进行前端校验
        if(!empName_validate("#empName_add_input")) {
          return false;
        }
        // 发送 Ajax 请求，校验员工名是否已存在
        $.ajax({
          url: "${app_path}/checkEmpName",
          data: "empName=" + $(this).val().trim(),
          type: "GET",
          success: function(result) {
            if(result.code == "100") {
              show_validate_msg("#empName_add_input", "success", "员工名可用!");
              // 给员工保存按钮添加一个自定义属性，用来表示员工名校验成功或失败信息
              $("#emp_add_modal_submit_btn").attr("ajax-empName-validate", "success");
            } else if (result.code == "200") {
              show_validate_msg("#empName_add_input", "fail", result.extend.va_msg);
              $("#emp_add_modal_submit_btn").attr("ajax-empName-validate", "fail");
              //$("#emp_add_modal_submit_btn").attr("ajax-validate-fail-msg", result.extend.va_msg);
            }
          }
        });
      });

      // 给所有单个删除按钮绑定单击事件
      $(document).on("click", ".delete_btn", function(){
        if( confirm("确认要删除【" + $(this).attr("delete-empName") + "】员工吗？") ) {
          // 发送删除的 Ajax 请求
          $.ajax({
            //url: "${app_path}/deleteEmpById/" + $(this).attr("delete-empId"),
            url: "${app_path}/deleteEmp/" + $(this).attr("delete-empId"),
            type: "DELETE",
            success: function(result) {
              alert(result.msg);
              if(result.code == "100") {
                // 跳转回当前页面
                to_page(currentPage);
              }else {
                return false;
              }
            }
          });
        }
      });

      // 给全选复选框绑定单击事件
      $("#check_all").click(function() {
        //alert($(this).prop("checked"));
        $(".check_item").prop("checked", $(this).prop("checked"));
      });

      // 给每个员工项前面的复选框绑定单击事件
      $(document).on("click", ".check_item", function() {
        // 判断当前所有员工项前面的复选框是否全部选中
        //alert($(".check_item:checked").size());
        //alert($(".check_item").size());
        if( $(".check_item:checked").size() == $(".check_item").size() ) {
          $("#check_all").prop("checked", true);
        } else {
          $("#check_all").prop("checked", false);
        }
      });

      // 给批量删除按钮绑定单击事件
      $("#emps_batch_del_btn").click(function() {
        // 获取员工列表中所有选中的复选框
        var checkedBox = $(".check_item:checked");
        var empNamesStr = "";
        var empIdsStr = "";
        $.each(checkedBox, function() {
          //alert($(this).parent().parent().find("td:eq(2)").text());
          //empNameStr += $(this).parent().parent().find("td:eq(2)").text();
          empNamesStr += $(this).parents("tr").find("td:eq(2)").text() + ",";
          //alert($(this).parents().find("td:eq(1)").text());
          empIdsStr += $(this).parents("tr").find("td:eq(1)").text() + "-";
          //alert(checkedBox.length);
          /* if(index < checkedBox.length - 1) {
              empNameStr += ",";
              empIdsStr += "-";
          } */
        });
        // 去除名字和编号字符串中多余的逗号和短横杠分隔符
        empNamesStr = empNamesStr.substring(0, empNamesStr.length - 1);
        empIdsStr = empIdsStr.substring(0, empIdsStr.length - 1);
        //alert(empNamesStr);
        //alert(empIdsStr);
        if( confirm("确定要删除【" + empNamesStr + "】员工吗？") ) {
          // 发送批量删除的 Ajax 请求
          $.ajax({
            //url: "${app_path}/deleteEmps/" + empIdsStr,
            url: "${app_path}/deleteEmp/" + empIdsStr,
            type: "DELETE",
            success: function(result) {
              alert(result.msg);
              if(result.code == "100") {
                // 跳转回当前页面
                to_page(currentPage);
              }else {
                return false;
              }
            }
          });
        }
      });
    });

    /*
    页面未加载完成，找不到 emp_del_modal_btn 按钮
    $("#emp_del_modal_btn").click(function() {
        alert(1);
    });*/
    function to_page(pageNum) {
      // 清除 #check_all 复选框的选中状态
      $("#check_all").prop("checked", false);
      $.ajax({
        url : "${app_path}/emps",
        data : "pageNum=" + pageNum,
        type : "GET",
        success : function(result) {
          //console.log(result);
          // 1、解析并显示员工信息
          build_emps_table(result);
          // 2、解析并显示分页信息
          build_page_info(result);
          // 3、解析并显示分页条
          build_page_nav(result);
        }
      });
    }

    function build_emps_table(result) {
      // 清空表格
      $("#emps_table tbody").empty();
      // 获取 json 格式数据中的员工信息数据
      var emps = result.extend.pageInfo.list;
      //alert(emps);

      // 遍历员工列表，显示在表格中
      $.each(emps, function(index, item) {
        //alert(item.empName);
        var checkboxTd = $("<td></td>").append("<input type=\"checkbox\" class=\"check_item\">");
        var empIdTd = $("<td></td>").append(item.empId);
        var empNameTd = $("<td></td>").append(item.empName);
        var emailTd = $("<td></td>").append(item.email);
        var genderTd = $("<td></td>").append(item.gender);
        var deptName = (item.department != null) ? item.department.deptName
                : null;
        var deptNameTd = $("<td></td>").append(deptName);
        /*
            <button class="btn btn-primary btn-sm">
                <span class="glyphicon glyphicon-pencil"></span>
                编辑
            </button>
            <button class="btn btn-danger btn-sm">
                <span class="glyphicon glyphicon-trash"></span>
                删除
            </button>
         */
        var editBtn = $("<button></button>").addClass(
                "btn btn-primary btn-sm edit_btn").append(
                $("<span></span>").addClass("glyphicon glyphicon-pencil"))
                .append("编辑");
        // 为编辑按钮添加自定义属性，记录当前正在编辑的员工的编号
        editBtn.attr("edit-empId", item.empId);
        var delBtn = $("<button></button>").addClass(
                "btn btn-danger btn-sm delete_btn").append(
                $("<span></span>").addClass("glyphicon glyphicon-trash"))
                .append("删除");
        // 为删除按钮添加自定义属性，记录当前正在删除的员工的编号和姓名
        delBtn.attr("delete-empId", item.empId);
        delBtn.attr("delete-empName", item.empName);
        var btnTd = $("<td></td>").append(editBtn).append(" ").append(
                delBtn);
        // append 方法执行完成后还是返回原来的元素
        $("<tr></tr>").append(checkboxTd).append(empIdTd).append(empNameTd).append(emailTd)
                .append(genderTd).append(deptNameTd).append(btnTd)
                .appendTo("#emps_table tbody");
      });
    }

    // 解析显示分页信息
    function build_page_info(result) {
      // 清空分页条信息
      $("#page_info").empty();
      var pageInfo = result.extend.pageInfo;
      var pageNum = pageInfo.pageNum;
      var pages = pageInfo.pages;
      var total = pageInfo.total;
      $("#page_info").append(
              "当前第" + pageNum + "页, 共有" + pages + "页, 总共" + total + "条记录");
      // 全局保存总记录数以及当前页码
      totalRecord = total;
      currentPage = pageNum;
    }

    // 解析显示分页条
    function build_page_nav(result) {
      // 清空分页条
      $("#page_nav").empty();
      var pageInfo = result.extend.pageInfo;
      // 分页条
      var pageUl = $("<ul></ul>").addClass("pagination");
      // 首页
      var firstLi = $("<li></li>").append($("<a></a>").append("首页"));
      if (pageInfo.isFirstPage) {
        firstLi.addClass("disabled");
      } else {
        firstLi.click(function() {
          to_page(1);
        });
      }

      pageUl.append(firstLi);
      // 上一页
      var prePageLi = $("<li></li>").append(
              $("<a></a>").append($("<span></span>").append("&laquo;")));
      if (pageInfo.hasPreviousPage) {
        prePageLi.click(function() {
          //to_page(pageInfo.prePage);
          to_page(pageInfo.pageNum - 1);
        });
      } else {
        prePageLi.addClass("disabled");
      }
      pageUl.append(prePageLi);
      // 显示的分页页码
      $.each(pageInfo.navigatepageNums, function(index, item) {
        var navigatePageLi = $("<li></li>").append(
                $("<a></a>").append(item));
        if (item == pageInfo.pageNum) {
          navigatePageLi.addClass("active");
        }
        navigatePageLi.click(function() {
          to_page(item);
        });
        pageUl.append(navigatePageLi);
      });

      // 下一页
      var nextPageLi = $("<li></li>").append(
              $("<a></a>").append($("<span></span>").append("&raquo;")));
      if (pageInfo.hasNextPage) {
        nextPageLi.click(function() {
          //to_page(pageInfo.nextPage);
          to_page(pageInfo.pageNum + 1);
        });
      } else {
        nextPageLi.addClass("disabled");
      }
      pageUl.append(nextPageLi);
      // 尾页
      var lastLi = $("<li></li>").append($("<a></a>").append("尾页"));
      if (pageInfo.isLastPage) {
        lastLi.addClass("disabled");
      } else {
        lastLi.click(function() {
          to_page(pageInfo.pages);
        });
      }
      pageUl.append(lastLi);
      // 分页条框架
      //var pageNav = $("<nav></nav>").attr("aria-label", "Page navigation");
      //pageNav.append(pageUl).appendTo("#page_nav");
      pageUl.appendTo("#page_nav");
    }

    // 查出所有的部门信息，显示在模态框中的下拉列表框中
    function getDepts(elem) {
      // 每次 Ajax 请求之前，清空下拉列表数据
      $(elem).empty();

      $.ajax({
        url:"${app_path}/depts",
        type:"GET",
        success:function(result){
          //console.log(result);
          /*$.each(result.extend.depts, function(index, item) {
              $("#dept_names_update_select").append($("<option></option>").append(item.deptName).attr("value", item.deptId));
          });*/

          //alert(result.extend.depts);
          $.each(result.extend.depts, function() {
            var elemOption = $("<option></option>").append(this.deptName)
                    .attr("value", this.deptId);
            $(elem).append(elemOption);
          });
          //alert($(elem).html());
        }
      });
    }

    // 校验邮箱信息的合法性
    function email_validate(elem) {
      // 校验邮箱信息
      var email = $(elem).val().trim();
      var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;

      if(!regEmail.test(email)) {
        show_validate_msg(elem, "fail", "邮箱格式不合法！例如：email@163.com");
        return false;
      } else {
        show_validate_msg(elem, "success", "");
        return true;
      }
    }

    // 校验员工名的合法性
    function empName_validate(elem) {
      // 获取员工名
      var empName = $(elem).val().trim();
      //alert($("#empName_add_input").val());
      //alert(empName);
      // 员工名必须由大小写字母或数字或下划线或横杠或中文汉字组成，且长度在 [6, 16] 范围内
      // 注意，不能随意添加空格
      var regEmpName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5}$)/;
      //var regEmpName = /^[a-zA-Z0-9\u2E80-\u9FFF_-]{6,16}$/;
      //alert(regEmpName.test(empName));
      if(!regEmpName.test(empName)) {
        //alert("员工名不合法！员工名可以是2-5位中文，也可以是6-16位英文字母数字组合");
        // 给表单的输入框中父元素的class添加 has-error
        show_validate_msg(elem, "fail", "员工名不合法！员工名可以是2-5位中文，也可以是6-16位英文字母数字组合");
        /* $("#empName_add_input").parent().addClass("has-error");
        //<span id="helpBlock2" class="help-block">A block of help text that breaks onto a new line and may extend beyond one line.</span>
        $("#empName_add_input").next("span")
                .text("员工名不合法！员工名可以是2-5位中文，也可以是6-16位英文字母数字组合"); */
        return false;
      } else { // 清空错误状态信息
        show_validate_msg(elem, "success", "");
        /* $("#empName_add_input").parent().addClass("has-success");
        $("#empName_add_input").next("span").text(""); */
        return true;
      }
    }

    /*
     * 	显示校验信息
     *		elem: 传入 jQuery 元素
     * 		status:校验状态（成功、失败）
     * 		msg:校验失败时的错误提示信息
     */
    function show_validate_msg(elem, status, msg) {
      // 清除当前元素的校验状态
      $(elem).parent().removeClass("has-success has-error");
      $(elem).next("span").text("");
      if("success" == status) {
        $(elem).parent().addClass("has-success");
        $(elem).next("span").text(msg);
      }else if ("fail" == status) {
        $(elem).parent().addClass("has-error");
        $(elem).next("span").text(msg);
      }
    }

    // 表单完整重置（数据和样式）
    function reset_form(elem) {
      // 重置表单内容
      $(elem)[0].reset();
      // 清空表单样式
      // 清除样式
      $(elem).find("*").removeClass("has-error has-success");
      // 清除错误信息
      $(elem).find(".help-block").text("");
    }

    // 发送 Ajax 请求，获取指定编号的员工信息
    function getEmpById(empId) {
      $.ajax({
        url: "${app_path}/empById/" + empId,
        type: "GET",
        success: function(result) {
          //console.log(result);
          var empData = result.extend.employee;
          $("#empName_update_static").text(empData.empName);
          $("#email_update_input").val(empData.email);
          $("#empEditModal input[type=radio]").val([empData.gender]);
          $("#dept_names_update_select").val([empData.dId]);
        }
      });
    }
  </script>
</head>
<body>
<!-- 员工添加的模态框 -->
<!-- Modal -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog"
     aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"
                aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <h4 class="modal-title" id="myModalLabel1">员工添加</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal">
          <div class="form-group">
            <label class="col-sm-2 control-label">empName</label>
            <div class="col-sm-10">
              <input type="text" name="empName" class="form-control"
                     id="empName_add_input" placeholder="empName"/>
              <span class="help-block"></span>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">email</label>
            <div class="col-sm-10">
              <input type="text" name="email" class="form-control"
                     id="email_add_input" placeholder="email@163.com"/>
              <span class="help-block"></span>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">gender</label>
            <div class="col-sm-10">
              <label class="radio-inline">
                <input type="radio" name="gender" id="gender1_add_input"
                       value="男" checked="checked"> 男
              </label>
              <label class="radio-inline">
                <input type="radio" name="gender" id="gender2_add_input"
                       value="女"> 女
              </label>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">deptName</label>
            <div class="col-sm-4">
              <!-- 部门名提交部门编号即可 -->
              <select class="form-control" name="dId" id="dept_names_add_select">
              </select>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal" id="emp_add_modal_close_btn">关闭</button>
        <button type="button" class="btn btn-primary" id="emp_add_modal_submit_btn">保存</button>
      </div>
    </div>
  </div>
</div>
<!-- 员工修改的模态框 -->
<!-- Modal -->
<div class="modal fade" id="empEditModal" tabindex="-1" role="dialog"
     aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"
                aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        <h4 class="modal-title" id="myModalLabel2">员工修改</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal">
          <div class="form-group">
            <label class="col-sm-2 control-label">empName</label>
            <div class="col-sm-10">
              <p name="empName" class="form-control-static" id="empName_update_static"></p>
              <span class="help-block"></span>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">email</label>
            <div class="col-sm-10">
              <input type="text" name="email" class="form-control"
                     id="email_update_input" placeholder="email@163.com"/>
              <span class="help-block"></span>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">gender</label>
            <div class="col-sm-10">
              <label class="radio-inline">
                <input type="radio" name="gender" id="gender1_update_input"
                       value="男" checked="checked"> 男
              </label>
              <label class="radio-inline">
                <input type="radio" name="gender" id="gender2_update_input"
                       value="女"> 女
              </label>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label">deptName</label>
            <div class="col-sm-4">
              <!-- 部门名提交部门编号即可 -->
              <select class="form-control" name="dId" id="dept_names_update_select">
              </select>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal" id="emp_edit_modal_close_btn">关闭</button>
        <button type="button" class="btn btn-primary" id="emp_update_modal_submit_btn">更新</button>
      </div>
    </div>
  </div>
</div>
<!-- 搭建显示页面 -->
<div class=".container">
  <!-- 标题 -->
  <div class="row">
    <div class="col-md-12">
      <h1>SSM-CRUD</h1>
    </div>
  </div>
  <!-- 按钮 -->
  <div class="row">
    <div class="col-md-4 col-md-offset-8">
      <button class="btn btn-primary" id="emp_add_modal_btn">新增</button>
      <button class="btn btn-danger" id="emps_batch_del_btn">删除</button>
    </div>
  </div>
  <!-- 显示表格数据 -->
  <div class="row">
    <div class="col-md-12">
      <table class="table table-hover" id="emps_table">
        <thead>
        <tr>
          <th><input type="checkbox" id="check_all"></th>
          <th>#</th>
          <th>empName</th>
          <th>email</th>
          <th>gender</th>
          <th>deptName</th>
          <th>操作</th>
        </tr>
        </thead>
        <tbody>

        </tbody>
      </table>
    </div>
  </div>
  <!-- 显示分页信息 -->
  <div class="row">
    <!-- 分页文字信息 -->
    <div class="col-md-6" id="page_info"></div>
    <!-- 分页条信息 -->
    <div class="col-md-6" id="page_nav"></div>
  </div>
</div>
</body>
</html>