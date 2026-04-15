<#import "../layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">
            <div class="card shadow-sm">
                <div class="card-body p-4 text-center">
                    <#if messageType!"info" == "success">
                        <div class="alert alert-success mb-4">
                            ${message!"Операцію виконано успішно."}
                        </div>
                    <#elseif messageType!"info" == "error">
                        <div class="alert alert-danger mb-4">
                            ${message!"Сталася помилка."}
                        </div>
                    <#else>
                        <div class="alert alert-info mb-4">
                            ${message!"Інформаційне повідомлення."}
                        </div>
                    </#if>

                    <a href="${redirectUrl!contextPath + '/hello'}" class="btn btn-dark">
                        ${redirectLabel!"Продовжити"}
                    </a>
                </div>
            </div>
        </div>
    </div>
</@layout.layout>