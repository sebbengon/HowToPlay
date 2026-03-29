<template>
  <Modal class="characters" @close="toggleModal('expressions')" v-if="modals.expressions">
    <h1>
      Uttrycksreferens
    </h1>
    <div id="expressions-list" v-for="expression in expressions" v-bind:key="expression.id">
      <h3 :class="expression.alignment">{{ expression.headline }}</h3>
      <p v-for="(paragraph, index) in expression.paragraphs" v-bind:key="index">{{ paragraph }}</p>
    </div>
  </Modal>
</template>

<script>
import expressionsJSON from '../../expressions'
import Modal from './Modal'
import { mapMutations, mapState } from 'vuex'

export default {
  components: {
    Modal,
  },
  data: function() {
    return {
      expressions: expressionsJSON,
    }
  },
  computed: {
    ...mapState(['modals']),
  },
  methods: {
    ...mapMutations(['toggleModal']),
  },
}
</script>

<style lang="scss" scoped>
@import '../../vars.scss';

h1 {
  margin: 0 40px;
  color: $fabled;
  svg {
    vertical-align: middle;
  }
}

h3 {
  padding-top: 20px;
}
h3.intruder {
  color: $demon;
}
h3.loyal {
  color: $townsfolk;
}
h3.guest {
  color: $traveler;
}
h3.legend {
  color: $fabled;
}

p {
  margin: 5px 0 15px 0;
}

#expressions-list {
  max-width: 60ch;
}
/** break into 1 column below 1200px **/
@media screen and (max-width: 1199.98px) {
  .modal {
    max-width: 60%;
  }
}

/** trim icon size on maximized one-column sheet **/
@media screen and (max-width: 991.98px) {
  .characters .modal.maximized ul li .icon {
    width: 5.1vh;
  }
}

a {
  color: $fabled !important;
  transition: all 0.3s;
}
.text-blue {
  color: $townsfolk !important;
  transition: all 0.3s;
}
.text-red {
  color: $demon !important;
  transition: all 0.3s;
}
a:hover {
  opacity: 0.6;
  transition: all 0.3s;
}
</style>
