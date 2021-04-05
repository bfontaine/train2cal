<template>
  <div>
    <form @submit="sendForm">
      <label>
        {{ $t('reference_label') }}
        <input v-model="tripReference" placeholder="XYZWZZ" required/>
      </label>
      <label>
        {{ $t('name_label') }}
        <input v-model="tripName" :placeholder="$t('default_name')" autocomplete="family-name" required/>
      </label>
      <input type="submit" :value="$t('submit')"/>
    </form>
    <a v-if="icalhref" :href="icalhref" download="train.ics">{{ $t('get_event') }}</a>
  </div>
</template>

<script>
export default {
  data() {
    this.$i18n.locale = 'fr';

    return {
      locale: "fr",
      icalhref: null,

      // tests
      tripReference: "",
      tripName: ""
    }
  },
  methods: {
    sendForm(e) {
      e.preventDefault();
      let view = this;

      fetch("/api/check?" +
          "ref=" + encodeURIComponent(this.tripReference) +
          "&name=" + encodeURIComponent(this.tripName))
          .then(function (response) {
            response.json().then(function (body) {
              if (body.ok) {
                view.tripReference = body.reference;
                view.tripName = body.name;

                view.icalhref = body.icalhref;
              }
            });
          });
    }
  },
  watch: {
    locale(value) {
      this.$i18n.locale = value;
    }
  }
}
</script>

<style>
/* ... */
</style>

<i18n>
{
  "en": {
    "reference_label": "Reference:",
    "name_label": "Name:",
    "default_name": "Doe",
    "submit": "OK",
    "get_event": "Get calendar event"
  },
  "fr": {
    "reference_label": "Référence :",
    "name_label": "Nom :",
    "default_name": "Dupont",
    "submit": "OK",
    "get_event": "Télécharger l'évènement"
  }
}
</i18n>