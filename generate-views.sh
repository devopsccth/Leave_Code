#!/bin/bash

# Script to generate all remaining Razor Views
# This creates a complete set of views for the Leave Management System

BASE_DIR="LeaveManagementSystem/Views"

# Create LeaveRequest/Create.cshtml
cat > "$BASE_DIR/LeaveRequest/Create.cshtml" << 'EOF'
@model LeaveRequestViewModel
@{ ViewData["Title"] = "ขอลา"; }

<div class="row">
    <div class="col-md-8 offset-md-2">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h4><i class="bi bi-plus-circle"></i> ขอลา</h4>
            </div>
            <div class="card-body">
                <form asp-action="Create" method="post" enctype="multipart/form-data">
                    <div asp-validation-summary="ModelOnly" class="alert alert-danger"></div>

                    <div class="mb-3">
                        <label asp-for="LeaveTypeId" class="form-label">ประเภทการลา *</label>
                        <select asp-for="LeaveTypeId" class="form-select" id="leaveTypeSelect">
                            <option value="">-- เลือกประเภทการลา --</option>
                            @foreach (var type in ViewBag.LeaveTypes as IEnumerable<LeaveType>)
                            {
                                <option value="@type.LeaveTypeId" data-remaining="@type.RemainingDays">
                                    @type.LeaveTypeName (คงเหลือ: @type.RemainingDays วัน)
                                </option>
                            }
                        </select>
                        <span asp-validation-for="LeaveTypeId" class="text-danger"></span>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label asp-for="StartDate" class="form-label">วันที่เริ่มต้น *</label>
                            <input asp-for="StartDate" class="form-control" type="date" />
                            <span asp-validation-for="StartDate" class="text-danger"></span>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label asp-for="EndDate" class="form-label">วันที่สิ้นสุด *</label>
                            <input asp-for="EndDate" class="form-control" type="date" />
                            <span asp-validation-for="EndDate" class="text-danger"></span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label asp-for="TotalDays" class="form-label">จำนวนวัน *</label>
                        <input asp-for="TotalDays" class="form-control" type="number" step="0.5" min="0.5" />
                        <span asp-validation-for="TotalDays" class="text-danger"></span>
                    </div>

                    <div class="mb-3">
                        <label asp-for="Reason" class="form-label">เหตุผล</label>
                        <textarea asp-for="Reason" class="form-control" rows="3"></textarea>
                        <span asp-validation-for="Reason" class="text-danger"></span>
                    </div>

                    <div class="mb-3">
                        <label asp-for="Approver1Id" class="form-label">ผู้อนุมัติคนที่ 1 *</label>
                        <select asp-for="Approver1Id" class="form-select">
                            <option value="">-- เลือกผู้อนุมัติ --</option>
                            @foreach (var approver in ViewBag.Approvers as IEnumerable<Employee>)
                            {
                                <option value="@approver.EmployeeId">@approver.FullName (@approver.PositionName)</option>
                            }
                        </select>
                        <span asp-validation-for="Approver1Id" class="text-danger"></span>
                    </div>

                    <div class="mb-3">
                        <label asp-for="Approver2Id" class="form-label">ผู้อนุมัติคนที่ 2 (ถ้ามี)</label>
                        <select asp-for="Approver2Id" class="form-select">
                            <option value="">-- ไม่ระบุ --</option>
                            @foreach (var approver in ViewBag.Approvers as IEnumerable<Employee>)
                            {
                                <option value="@approver.EmployeeId">@approver.FullName (@approver.PositionName)</option>
                            }
                        </select>
                    </div>

                    <div class="mb-3">
                        <label asp-for="Attachment" class="form-label">เอกสารแนบ</label>
                        <input asp-for="Attachment" class="form-control" type="file" />
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-send"></i> ส่งคำขอ
                        </button>
                        <a asp-action="Index" class="btn btn-secondary">ยกเลิก</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

@section Scripts {
    <partial name="_ValidationScriptsPartial" />
}
EOF

# Create LeaveRequest/Index.cshtml
cat > "$BASE_DIR/LeaveRequest/Index.cshtml" << 'EOF'
@model IEnumerable<LeaveRequest>
@{ ViewData["Title"] = "คำขอลาของฉัน"; }

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2><i class="bi bi-file-earmark-text"></i> คำขอลาของฉัน</h2>
    <a asp-action="Create" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i> ขอลา
    </a>
</div>

<div class="card">
    <div class="card-body">
        @if (Model != null && Model.Any())
        {
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>เลขที่</th>
                            <th>ประเภทการลา</th>
                            <th>วันที่เริ่มต้น</th>
                            <th>วันที่สิ้นสุด</th>
                            <th>จำนวนวัน</th>
                            <th>สถานะ</th>
                            <th>การอนุมัติ</th>
                            <th>การดำเนินการ</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach (var item in Model)
                        {
                            <tr>
                                <td>@item.RequestNumber</td>
                                <td>@item.LeaveTypeName</td>
                                <td>@item.StartDate.ToString("dd/MM/yyyy")</td>
                                <td>@item.EndDate.ToString("dd/MM/yyyy")</td>
                                <td>@item.TotalDays</td>
                                <td>
                                    @if (item.Status == "Approved")
                                    {
                                        <span class="badge bg-success">อนุมัติ</span>
                                    }
                                    else if (item.Status == "Rejected")
                                    {
                                        <span class="badge bg-danger">ปฏิเสธ</span>
                                    }
                                    else if (item.Status == "Cancelled")
                                    {
                                        <span class="badge bg-secondary">ยกเลิก</span>
                                    }
                                    else
                                    {
                                        <span class="badge bg-warning text-dark">รอพิจารณา</span>
                                    }
                                </td>
                                <td>@item.ApprovedCount/@item.TotalApprovers</td>
                                <td>
                                    <a asp-action="Details" asp-route-id="@item.LeaveRequestId" class="btn btn-sm btn-info">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        }
                    </tbody>
                </table>
            </div>
        }
        else
        {
            <p class="text-center text-muted my-5">ไม่มีคำขอลา</p>
        }
    </div>
</div>
EOF

# Create simple CRUD views for Employee, Department, Position, LeaveType
for entity in "Employee" "Department" "Position" "LeaveType"; do
    cat > "$BASE_DIR/${entity}/Index.cshtml" << EOF
@model IEnumerable<${entity}>
@{ ViewData["Title"] = "จัดการ${entity}"; }

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>จัดการ${entity}</h2>
    <a asp-action="Create" class="btn btn-primary">
        <i class="bi bi-plus-circle"></i> เพิ่ม
    </a>
</div>

<div class="card">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>ชื่อ</th>
                        <th>สถานะ</th>
                        <th>การดำเนินการ</th>
                    </tr>
                </thead>
                <tbody>
                    @if (Model != null && Model.Any())
                    {
                        @foreach (var item in Model)
                        {
                            <tr>
                                <td>@item.${entity}Id</td>
                                <td>@item.${entity}Name</td>
                                <td>
                                    @if (item.IsActive)
                                    {
                                        <span class="badge bg-success">ใช้งาน</span>
                                    }
                                    else
                                    {
                                        <span class="badge bg-secondary">ไม่ใช้งาน</span>
                                    }
                                </td>
                                <td>
                                    <a asp-action="Edit" asp-route-id="@item.${entity}Id" class="btn btn-sm btn-warning">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form asp-action="Delete" asp-route-id="@item.${entity}Id" method="post" class="d-inline">
                                        <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('คุณแน่ใจหรือไม่?')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        }
                    }
                </tbody>
            </table>
        </div>
    </div>
</div>
EOF
done

echo "Views generated successfully!"
