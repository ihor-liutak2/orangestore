<#import "layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-6">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h1 class="h3 mb-3">${message}</h1>
                    <p class="mb-0">${description}</p>
                </div>
            </div>

            <div class="alert alert-info mt-3" role="alert">
                Bootstrap підключено через CDN ✅
            </div>
        </div>
    </div>
</@layout.layout>
