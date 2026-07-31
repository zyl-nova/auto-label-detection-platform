<template>
  <div class="page">
    <div class="toolbar">
      <el-input v-model="keyword" placeholder="搜索样本名 / 项目名" :prefix-icon="Search" clearable />
      <el-select v-model="typeFilter" placeholder="样本类型">
        <el-option label="全部" value="全部" />
        <el-option label="图像" value="图像" />
        <el-option label="结构化数据" value="结构化数据" />
      </el-select>
      <el-button type="primary" @click="router.push('/sampleCenter/toUpload')">导入样本</el-button>
    </div>

    <el-alert class="hint" type="info" show-icon :closable="false" title="已完成的标注任务可以在“标注”页面一键导入为样本集，训练任务会直接读取这里的样本。" />

    <el-table :data="filteredSamples" height="calc(100vh - 300px)" empty-text="暂无样本">
      <el-table-column prop="id" label="样本ID" width="100" />
      <el-table-column prop="name" label="样本名称" min-width="180" />
      <el-table-column prop="type" label="样本类型" width="120" />
      <el-table-column prop="count" label="样本量" width="120" />
      <el-table-column prop="projectName" label="所属项目" min-width="130" />
      <el-table-column prop="createTime" label="录入时间" min-width="160" />
      <el-table-column prop="creator" label="录入人" width="110" />
      <el-table-column label="操作" width="300">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">查看</el-button>
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="primary" @click="createTrainTask(row)">创建训练</el-button>
          <el-button link type="danger" @click="deleteSample(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="detailVisible" title="样本集详情" width="600px">
      <el-descriptions v-if="detailTarget" :column="1" border>
        <el-descriptions-item label="样本名称">{{ detailTarget.name }}</el-descriptions-item>
        <el-descriptions-item label="样本类型">{{ detailTarget.type }}</el-descriptions-item>
        <el-descriptions-item label="样本数量">{{ detailTarget.count }}</el-descriptions-item>
        <el-descriptions-item label="所属项目">{{ detailTarget.projectName }}</el-descriptions-item>
        <el-descriptions-item label="来源任务">{{ sourceTaskName(detailTarget.sourceTaskId) }}</el-descriptions-item>
        <el-descriptions-item label="录入时间">{{ detailTarget.createTime }}</el-descriptions-item>
        <el-descriptions-item label="说明">{{ detailTarget.description || '暂无说明' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button v-if="detailTarget" type="primary" @click="openEdit(detailTarget)">编辑</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editVisible" title="编辑样本集" width="600px">
      <el-form label-width="90px">
        <el-form-item label="样本名称">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="样本类型">
          <el-select v-model="editForm.type">
            <el-option label="图像" value="图像" />
            <el-option label="结构化数据" value="结构化数据" />
          </el-select>
        </el-form-item>
        <el-form-item label="样本数量">
          <el-input-number v-model="editForm.count" :min="1" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="editForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveSample">保存</el-button>
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
import type { SampleSet } from '@/stores/businessStore'

const router = useRouter()
const { business } = allStore()
const keyword = ref('')
const typeFilter = ref<'全部' | '图像' | '结构化数据'>('全部')
const detailVisible = ref(false)
const editVisible = ref(false)
const detailTarget = ref<SampleSet>()
const editId = ref<number>()
const editForm = ref({
  name: '',
  type: '图像' as SampleSet['type'],
  count: 1,
  description: '',
})

const filteredSamples = computed(() => {
  const text = keyword.value.trim()
  return business.samples.filter((item) => {
    const matchType = typeFilter.value === '全部' || item.type === typeFilter.value
    const matchText = !text || `${item.name}${item.projectName}`.includes(text)
    return matchType && matchText
  })
})

const sourceTaskName = (id?: number) => {
  if (!id) return '手动导入'
  return business.labelTasks.find((item) => item.id === id)?.name || `任务${id}`
}

const openDetail = (sample: SampleSet) => {
  detailTarget.value = sample
  detailVisible.value = true
}

const openEdit = (sample: SampleSet) => {
  editId.value = sample.id
  editForm.value = {
    name: sample.name,
    type: sample.type,
    count: sample.count,
    description: sample.description,
  }
  detailVisible.value = false
  editVisible.value = true
}

const saveSample = () => {
  if (!editId.value || !editForm.value.name.trim()) {
    ElMessage.warning('请填写样本名称')
    return
  }
  business.updateSample(editId.value, {
    name: editForm.value.name.trim(),
    type: editForm.value.type,
    count: editForm.value.count,
    description: editForm.value.description,
  })
  editVisible.value = false
  ElMessage.success('样本集已保存')
}

const createTrainTask = (sample: SampleSet) => {
  router.push({ path: '/taskCenter/toTrain', query: { sampleId: sample.id } })
}

const deleteSample = (id: number) => {
  ElMessageBox.confirm('确认删除该样本集？', '删除样本集', { type: 'warning' })
    .then(() => {
      business.deleteSample(id)
      ElMessage.success('样本已删除')
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
  margin-bottom: 14px;
}

.hint {
  margin-bottom: 14px;
}
</style>
