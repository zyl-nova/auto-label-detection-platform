<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索模型名 / 项目名 / 类别" :prefix-icon="Search" clearable />
      <el-select v-model="statusFilter" placeholder="模型状态">
        <el-option label="全部" value="全部" />
        <el-option label="已导入" value="已导入" />
        <el-option label="已发布" value="已发布" />
      </el-select>
      <el-button type="primary" @click="router.push('/modelCenter/toImport')">导入模型</el-button>
    </div>

    <div class="cards">
      <div v-for="model in filteredModels" :key="model.id" class="card">
        <div class="card-head">
          <strong>{{ model.name }}</strong>
          <el-tag :type="model.status === '已发布' ? 'success' : 'info'">{{ model.status }}</el-tag>
        </div>
        <div class="meta">{{ model.taskType }} / {{ model.targetType }} / {{ model.projectName }}</div>
        <div class="desc">{{ model.description }}</div>
        <div class="metrics">
          <span>来源：{{ model.source }}</span>
          <span>mAP：{{ model.map }}</span>
        </div>
        <div class="actions">
          <el-button @click="openDetail(model)">查看</el-button>
          <el-button @click="openEdit(model)">编辑</el-button>
          <el-button :disabled="model.status === '已发布'" type="primary" @click="publish(model.id)">发布</el-button>
          <el-button @click="router.push('/workspace')">去工作区</el-button>
          <el-button type="danger" @click="deleteModel(model.id)">删除</el-button>
        </div>
      </div>
    </div>

    <el-dialog v-model="detailVisible" title="模型详情" width="620px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="模型名称">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="任务类型">{{ detailTarget.taskType }}</el-descriptions-item>
        <el-descriptions-item label="目标类别">{{ detailTarget.targetType }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detailTarget.status }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ detailTarget.source }}</el-descriptions-item>
        <el-descriptions-item label="mAP">{{ detailTarget.map }}</el-descriptions-item>
        <el-descriptions-item label="说明">{{ detailTarget.description || '暂无说明' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑模型" width="620px">
      <el-form label-width="90px">
        <el-form-item label="模型名称">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="任务类型">
          <el-select v-model="editForm.taskType">
            <el-option label="图像识别" value="图像识别" />
            <el-option label="视频识别" value="视频识别" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标类别">
          <el-select v-model="editForm.targetType">
            <el-option label="车辆" value="车辆" />
            <el-option label="电线" value="电线" />
            <el-option label="动物" value="动物" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="已导入" value="已导入" />
            <el-option label="已发布" value="已发布" />
          </el-select>
        </el-form-item>
        <el-form-item label="mAP">
          <el-input v-model="editForm.map" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="editForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveModel">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import allStore from '@/stores'
import type { ModelItem } from '@/stores/businessStore'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const statusFilter = ref<'全部' | '已导入' | '已发布'>('全部')
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<ModelItem>()
const editId = ref<number>()
const editForm = ref({
  name: '',
  taskType: '图像识别' as ModelItem['taskType'],
  targetType: '车辆' as ModelItem['targetType'],
  status: '已导入' as ModelItem['status'],
  map: '',
  description: '',
})

const filteredModels = computed(() => {
  const text = keyword.value.trim()
  return business.models.filter((item) => {
    const matchStatus = statusFilter.value === '全部' || item.status === statusFilter.value
    const matchText = !text || `${item.name}${item.projectName}${item.targetType}`.includes(text)
    return matchStatus && matchText
  })
})

const openDetail = (model: ModelItem) => {
  detailTarget.value = model
  detailVisible.value = true
}

const openEdit = (model: ModelItem) => {
  editId.value = model.id
  editForm.value = {
    name: model.name,
    taskType: model.taskType,
    targetType: model.targetType,
    status: model.status,
    map: model.map,
    description: model.description,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveModel = () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写模型名称')
    return
  }
  business.updateModel(editId.value, {
    name: editForm.value.name.trim(),
    taskType: editForm.value.taskType,
    targetType: editForm.value.targetType,
    status: editForm.value.status,
    map: editForm.value.map.trim() || '待评估',
    description: editForm.value.description,
  })
  editVisible.value = false
  ElMessage.success('模型已保存')
}

const publish = (id: number) => {
  business.publishModel(id)
  ElMessage.success('模型已发布，可在工作区调用')
}

const deleteModel = (id: number) => {
  ElMessageBox.confirm('确认删除该模型？', '删除模型', { type: 'warning' })
    .then(() => {
      business.deleteModel(id)
      ElMessage.success('模型已删除')
    })
    .catch(() => undefined)
}
</script>

<style scoped>
.page {
  padding: 22px;
}

.toolbar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 180px 120px;
  gap: 14px;
  margin-bottom: 18px;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.card {
  padding: 16px;
  border: 1px solid #d8dee9;
  border-radius: 8px;
  background: #fff;
}

.card-head,
.metrics,
.actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.meta,
.desc,
.metrics {
  margin-top: 10px;
  color: #667085;
  font-size: 13px;
}

.desc {
  min-height: 40px;
}

.actions {
  margin-top: 14px;
  flex-wrap: wrap;
  justify-content: flex-start;
}
</style>
